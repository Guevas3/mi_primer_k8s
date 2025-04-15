<!DOCTYPE html>
<html lang="es">
<body>

  <h1>🚀 Deploy de Proyecto Web en Kubernetes</h1>
  <p>Este documento te guiará paso a paso para levantar tu proyecto web en un entorno local con <strong>Kubernetes</strong> utilizando <strong>Minikube</strong>.</p>

  <h2>🛠️ Requisitos Previos</h2>
  <p>Asegúrate de tener instaladas las siguientes herramientas:</p>
  <ul>
    <li>🧰 <strong>Minikube:</strong> <a href="https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download">Instalar Minikube</a></li>
    <li>⚙️ <strong>kubectl:</strong> <a href="https://minikube.sigs.k8s.io/docs/handbook/kubectl/">Instalar kubectl</a></li>
    <li>🐳 <strong>Docker:</strong> <a href="https://minikube.sigs.k8s.io/docs/drivers/docker/">Instalar Docker Driver</a></li>
    <li>🔧 <strong>Git:</strong> <a href="https://git-scm.com/downloads/linux">Instalar Git</a></li>
  </ul>

  <h2>📂 Clonar Repositorios</h2>
  <p>Cloná los siguientes repositorios <strong>en la misma carpeta local</strong>:</p>
  <pre><code>git clone https://github.com/Guevas3/mi_primer_k8s.git
git clone https://github.com/Guevas3/static-website.git</code></pre>

  <h2>🧪 Iniciar Minikube</h2>
  <p>Dirigite a la carpeta donde se encuentran los archivos clonados y ejecutá:</p>
  <pre><code>minikube start --mount --mount-string="/ruta/a/static-website:/mnt/web"</code></pre>
  <blockquote>
    📌 Reemplazá <code>/ruta/a/static-website</code> con la ruta local real de tu carpeta del sitio web.
  </blockquote>

  <h2>📦 Aplicar Archivos en Kubernetes</h2>
  <p>Entrá a la carpeta <code>mi_primer_k8s</code> y ejecutá los siguientes comandos dentro de las carpetas correspondientes (<code>deployment</code>, <code>service</code>, <code>volume</code>):</p>
  <pre><code>kubectl apply -f .</code></pre>
  <p>Verificá que el pod esté corriendo:</p>
  <pre><code>kubectl get pod</code></pre>
  <p>✅ El estado del pod debe mostrar:</p>
  <ul>
    <li><code>READY: 1/1</code></li>
    <li><code>STATUS: Running</code></li>
  </ul>

  <h2>🌐 Levantar el Servicio Web</h2>
  <p>Ejecutá el siguiente comando para acceder al servicio:</p>
  <pre><code>minikube service sitio-web-service</code></pre>
  <blockquote>
    📁 <em><code>sitio-web-service</code> debe coincidir con el nombre del servicio definido en <code>servicio.yaml</code> dentro de la carpeta <code>service</code>.</em>
  </blockquote>

  <h2>🌉 Activar Ingress</h2>
  <p>Habilitá el complemento <code>ingress</code>:</p>
  <pre><code>minikube addons enable ingress</code></pre>
  <p>Aplicá el archivo <code>ingress.yaml</code> desde la carpeta <code>service</code>:</p>
  <pre><code>kubectl apply -f .</code></pre>

  <h2>🌍 Configurar Acceso por Nombre de Dominio</h2>
  <p>Obtené la IP de Minikube:</p>
  <pre><code>minikube ip</code></pre>
  <p>Editá el archivo <code>/etc/hosts</code> para usar un nombre personalizado:</p>
  <pre><code>echo "192.168.49.2 local.service" | sudo tee -a /etc/hosts</code></pre>
  <blockquote>
    📝 Reemplazá <code>192.168.49.2</code> por la IP que obtuviste con el comando anterior.
  </blockquote>

  <h2>🖥️ Acceder a la Página Web</h2>
  <p>Abrí tu navegador y entrá a:</p>
  <pre><code>http://local.service/</code></pre>

  <h2>🎉 ¡Listo!</h2>
  <p>Tu página web ahora está montada correctamente en Kubernetes.<br>
  ¡Tadán! 😄</p>

</body>
</html>


