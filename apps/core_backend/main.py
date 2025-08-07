from fastapi import FastAPI
from endpoints.routing import router as routing_router
from endpoints.geocoding import router as geocoding_router
from core.config import settings

app = FastAPI()
app.include_router(routing_router, prefix=settings.API_VERSION)
app.include_router(geocoding_router, prefix=settings.API_VERSION)

@app.get("/")
async def root():
    return {"message": "Welcome to the Navi4All Core Backend API"}
