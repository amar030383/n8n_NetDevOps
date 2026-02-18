from django.urls import path
from .views import RunShowView

urlpatterns = [
    path('run-show', RunShowView.as_view(), name='run-show'),
]
