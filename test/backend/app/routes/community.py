from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional
from app.database import get_db
from app.models import CommunityPost, User, Like
from pydantic import BaseModel
from datetime import datetime


class CommunityPostResponse(BaseModel):
    id: int
    user_id: int
    user_name: Optional[str] = None
    user_avatar: Optional[str] = None
    title: str
    content: str
    image_url: Optional[str] = None
    category: str
    likes_count: int
    comments_count: int
    is_liked: bool = False  # Whether current user has liked this post
    created_at: datetime
    
    class Config:
        from_attributes = True


class CommunityPostCreate(BaseModel):
    title: str
    content: str
    category: str
    image_url: Optional[str] = None


router = APIRouter()


@router.get("/posts", response_model=List[CommunityPostResponse])
async def list_posts(
    skip: int = 0,
    limit: int = 100,
    category: Optional[str] = None,
    current_user_id: int = 1,  # TODO: get from auth
    db: AsyncSession = Depends(get_db)
):
    """List all community posts with user info and like status"""
    try:
        from sqlalchemy import select, and_
        from sqlalchemy.orm import selectinload
        
        # Query posts with user relationship
        query = select(CommunityPost).options(selectinload(CommunityPost.user))
        
        if category:
            query = query.where(CommunityPost.category == category)
        
        query = query.order_by(CommunityPost.created_at.desc()).offset(skip).limit(limit)
        result = await db.execute(query)
        posts = result.scalars().all()
        
        # Build response with user info and like status
        response_posts = []
        for post in posts:
            try:
                # Check if current user liked this post
                like_exists = await db.execute(
                    select(Like).where(
                        and_(Like.post_id == post.id, Like.user_id == current_user_id)
                    )
                )
                is_liked = like_exists.scalar_one_or_none() is not None
                
                # Get user info - handle case where user might not exist
                user = post.user if hasattr(post, 'user') else None
                
                # If user relationship didn't load, fetch it manually
                if user is None:
                    user_result = await db.execute(
                        select(User).where(User.id == post.user_id)
                    )
                    user = user_result.scalar_one_or_none()
                
                response_posts.append(CommunityPostResponse(
                    id=post.id,
                    user_id=post.user_id,
                    user_name=user.name if user else "Unknown User",
                    user_avatar=user.avatar if user else None,
                    title=post.title,
                    content=post.content,
                    image_url=post.image_url,
                    category=post.category,
                    likes_count=post.likes_count,
                    comments_count=post.comments_count,
                    is_liked=is_liked,
                    created_at=post.created_at,
                ))
            except Exception as e:
                # Log error for this post but continue processing others
                print(f"Error processing post {post.id}: {e}")
                # Still add the post but with minimal info
                response_posts.append(CommunityPostResponse(
                    id=post.id,
                    user_id=post.user_id,
                    user_name="Unknown User",
                    user_avatar=None,
                    title=post.title,
                    content=post.content,
                    image_url=post.image_url,
                    category=post.category,
                    likes_count=post.likes_count,
                    comments_count=post.comments_count,
                    is_liked=False,
                    created_at=post.created_at,
                ))
        
        return response_posts
    except Exception as e:
        print(f"Error in list_posts: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


@router.post("/posts", response_model=CommunityPostResponse)
async def create_post(
    post: CommunityPostCreate,
    db: AsyncSession = Depends(get_db)
):
    """Create a new community post"""
    from sqlalchemy.orm import selectinload
    
    db_post = CommunityPost(user_id=1, **post.model_dump())  # TODO: get from auth
    db.add(db_post)
    await db.commit()
    await db.refresh(db_post)
    
    # Load user relationship
    await db.refresh(db_post, ["user"])
    
    user = db_post.user
    return CommunityPostResponse(
        id=db_post.id,
        user_id=db_post.user_id,
        user_name=user.name if user else None,
        user_avatar=user.avatar if user else None,
        title=db_post.title,
        content=db_post.content,
        image_url=db_post.image_url,
        category=db_post.category,
        likes_count=db_post.likes_count,
        comments_count=db_post.comments_count,
        is_liked=False,
        created_at=db_post.created_at,
    )


@router.post("/posts/{post_id}/like")
async def toggle_like_post(
    post_id: int,
    current_user_id: int = 1,  # TODO: get from auth
    db: AsyncSession = Depends(get_db)
):
    """Toggle like on a post (like if not liked, unlike if liked)"""
    from sqlalchemy import select, and_
    
    # Get the post
    result = await db.execute(
        select(CommunityPost).where(CommunityPost.id == post_id)
    )
    post = result.scalar_one_or_none()
    
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    
    # Check if user already liked the post
    like_result = await db.execute(
        select(Like).where(
            and_(Like.post_id == post_id, Like.user_id == current_user_id)
        )
    )
    existing_like = like_result.scalar_one_or_none()
    
    if existing_like:
        # Unlike: remove the like
        from sqlalchemy import delete
        await db.execute(delete(Like).where(Like.id == existing_like.id))
        post.likes_count = max(0, post.likes_count - 1)
        is_liked = False
    else:
        # Like: create new like
        new_like = Like(post_id=post_id, user_id=current_user_id)
        db.add(new_like)
        post.likes_count += 1
        is_liked = True
    
    await db.commit()
    await db.refresh(post)
    
    return {
        "liked": is_liked,
        "likes_count": post.likes_count
    }

