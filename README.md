//fork del git
fork del repositorio

//clonar git en archivos locales
cd //ruta de destino
git clone https://github.com/Guevas3/static-website.git

//iniciar minikube
sudo usermod -aG docker $USER && newgrp docker
minikube start --driver=docker

//creamos carpetas deployment, services y volumes
cd /home/guevas/Desktop/TP_Cloud/manifiestos_k8s
mkdir deployments services volumes

//agregamos la PersistentVolume
touch pv.yaml
//agregamos los argumentos del yaml

//agregamos la PersistentVolumeClaim
touch pvc.yaml
//agregamos los argumentos del yaml


//agregamos el deployment
cd /home/guevas/Desktop/TP_Cloud/manifiestos_k8s/deployments
touch web-deployment.yaml
//agregamos los argumentos del yaml

//agregamos el service
cd /home/guevas/Desktop/TP_Cloud/manifiestos_k8s/services
touch web-service.yaml

//aplicamos los manifiestos
kubectl apply -f /home/guevas/Desktop/TP_Cloud/manifiestos_k8s/volumes/pv.yaml
kubectl apply -f /home/guevas/Desktop/TP_Cloud/manifiestos_k8s/volumes/pvc.yaml
kubectl apply -f /home/guevas/Desktop/TP_Cloud/manifiestos_k8s/deployments/web-deployment.yaml
kubectl apply -f /home/guevas/Desktop/TP_Cloud/manifiestos_k8s/services/web-service.yaml

//acceder desde el navegador
minikube service sitio-web-service
//en el caso de que te tire error ingresar el siguiente comando y reiniciar sistema y correr minikube
sudo usermod -aG docker $USER
//luego checkeamos docker y si no tira error volver a ejecutar el primer comando
docker ps
minikube service sitio-web-service
