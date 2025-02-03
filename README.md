## Inicializando

```hcl
terraform init
terraform plan
terraform apply -auto-approve
```

## Criando namespace

```bash
kubectl create namespace projeto-modulo
```

## Aplicar o deploy

```bash
kubectl apply -f deployment.yaml
```

## Obter IP Externo

```bash
kubectl get svc -n projeto-modulo
```