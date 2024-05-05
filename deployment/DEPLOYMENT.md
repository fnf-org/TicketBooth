# How To Manually Manage This App

There are 2 main applications that are used for this app

- terraform to manage the cloud resources; databases, secrets, IAM privileges, etc.
- helm to manage the application in GKE

## Helm

* _What Is It?_
Helm is a pretty popular k8s manifest templating engine based on gotemplate.
Charts define of all the k8s objects that encompass the full application
deployment. Many of your favorite applications have helm charts that make it
seemless to manage third-party applications in kubernetes.

### Resources Defined

While this application isn't super complicated, it is good to go through the
things that get deployed when helm runs.

* Namespace is a logical border that has all the necessary objects for the
  application.
* ServiceAccount for the application that links to a Google principal allowing
  the pod to make authenticated GCP API requests.
* Deployment defines how to run the application. This app has the following
  containers in each deployed pod:
  * GCP credential manager
  * CloudSQL Proxy
  * TicketBooth Rails app
* Configmap maintains the non-secret values for the application and are set as
  environment variables
* Secret contains the private config values. This shouldn't be used directly
  as...
* ExternalSecret references a GCP SecretManager path that will configure the
  Secret that the app uses
* Service is a single network entrypoint for the application and helps load
  balance traffic across all available Pods
* Ingress defines the rules to apply to inbound traffic so that the app gets the
  traffic it needs. Think of it like an API Gateway or L7 HTTP Load Balancer
  config

### Running This (CLI)

In this directory, run the following to deploy the chart as if it hadn't been
deployed before.

```bash
helm install ticket-booth-prod -f env/base.yaml -f base/production.yaml ./chart --atomic
```

This takes the chart defined in `chart/` and the customization yaml files
`base` and `production` to generate the manifests that are applied to the
cluster. `--atomic` if there to rollback any changes if the deployment doesn't
succeed.

To update the app for a new app version, change the `image.tag` value in
`env/production.yaml` and then run

```bash
helm upgrade ticket-booth-prod -f env/base.yaml -f base/production.yaml ./chart --atomic
```

### Principals

1. The chart should be able to be deployed for multiple environments without any
   modifications to itself. _Value files contain the "Source of Truth"_
2. Safe to run production next to staging in the same k8s cluster and Namespace
3. Easy to automate because there are failsafes

## Terraform

The application needs to interact with other GCP resources, so these are defined
in Terraform.

* ServiceAccount allow the GKE ServiceAccount to assume it and has roles
  assigned to it that are specific for the app. No more, no less.
* CloudSQL instance and database. It is only accessible privately and uses AIM
  credentails to authenticate. No more passwords!
* Secretsmanager for the app secrets. It is version controlled, so rollbacks can
  be seemless.

It is curently desinged to only run one instance, but it would be very easy to
make it so a staging deployment can use the same terraform without stomping on
the production resources.
