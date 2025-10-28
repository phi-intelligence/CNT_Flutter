# CNT Media Platform Backend

FastAPI backend for the Christ New Tabernacle media platform.

## Setup

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Create a `.env` file based on `env.example`

4. Create the database:
```bash
createdb cnt_db
```

5. Run migrations:
```bash
alembic revision --autogenerate -m "Initial migration"
alembic upgrade head
```

6. Start the server:
```bash
uvicorn app.main:app --reload
```

The API will be available at http://localhost:8000
API documentation at http://localhost:8000/docs

