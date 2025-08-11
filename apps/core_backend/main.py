from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from endpoints.routing import router as routing_router
from endpoints.geocoding import router as geocoding_router
from core.config import settings

app = FastAPI(
    title="Navi4All Core Backend API",
    docs_url="/docs" if settings.DEBUG else None,
    redoc_url="/redoc" if settings.DEBUG else None,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(routing_router, prefix=settings.API_VERSION)
app.include_router(geocoding_router, prefix=settings.API_VERSION)

@app.get("/")
async def root():
    return {"message": "Welcome to the Navi4All Core Backend API"}
