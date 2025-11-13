from flask import Flask, Response, jsonify
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST, Gauge, Counter
import random
import time

app = Flask(__name__)

g_response_time_ms = Gauge('app_response_time_ms', 'Mock response time in milliseconds')
g_health = Gauge('app_health', 'App health status: 1 ok, 0 fail')
c_requests = Counter('app_requests_total', 'Total requests', ['endpoint'])


@app.route('/')
def root():
    start = time.time()
    c_requests.labels(endpoint='/').inc()
    simulated = random.uniform(0.05, 0.25)
    time.sleep(simulated)
    g_response_time_ms.set(simulated * 1000.0)
    g_health.set(1)
    return jsonify({
        "status": "ok",
        "response_time_ms": simulated * 1000.0
    })


@app.route('/healthz')
def healthz():
    g_health.set(1)
    return jsonify({"status": "ok"})


@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
