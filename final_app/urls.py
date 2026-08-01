"""
URL configuration for final_app project.
"""
from django.contrib import admin
from django.urls import include, path

from django.http import HttpResponse


def home_smoke_test_view(request):
    return HttpResponse("Hello World")

urlpatterns = [
    path("", home_smoke_test_view, name="root_smoke_test"),
    
    path("app/", include("hello_final.urls")),
    path('admin/', admin.site.urls),
]
