from django.urls import path
from .views import HealthCheckView, RunShowView

urlpatterns = [
    path('health', HealthCheckView.as_view(), name='health'),
    path('run-show', RunShowView.as_view(), name='run-show'),
]
