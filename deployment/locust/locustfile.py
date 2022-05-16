import os 
from lxml import html  

from locust import HttpUser, task

class HelloWorldUser(HttpUser):
    @task
    def hello_world(self):
        self.client.get("/events/8/ticket_requests")

    def on_start(self):
        self.username = os.environ.get('LOCUST_USER', 'test@test.test')
        self.password = os.environ.get('LOCUST_PASSWORD', 'testtest')
        landing_response = self.client.get("/users/sign_in")
        tree = html.fromstring(landing_response.text)
        csrf_token = tree.xpath('/html/head/meta[@name="csrf-token"]/@content')[0]
        auth_token = tree.xpath('//form/input[@name="authenticity_token"]/@value')[0]
        self.client.post("//users/sign_in",
            {"user[email]": self.username,
            "user[password]": self.password,
            "authenticity_token": auth_token},
            headers={"X-CSRFToken": csrf_token})
        print('Login with %s email and %s password', self.username, self.password)
