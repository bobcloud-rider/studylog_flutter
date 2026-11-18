#!/usr/bin/env python3
"""Backend demo Campus Report (khusus praktikum, TANPA login & tanpa HTTPS).

Hanya memakai pustaka standar Python, jadi tidak perlu pip install apa pun.

Jalankan:
    python tools/demo_api.py                 # server di 0.0.0.0:8000
    python tools/demo_api.py --port 8080

Endpoint:
    GET  /health          -> {"ok": true}
    POST /reports         -> 201 {serverId, created:true}   (laporan baru)
                             200 {serverId, created:false}  (clientReportId sudah ada)
                             400 {error}                    (validasi gagal)
    GET  /reports         -> daftar laporan yang diterima
    POST /mode            -> {"fail": true|false}  simulasi server error / mati
    POST /reset           -> kosongkan semua data (untuk ulang demo)

Uji cepat (PowerShell / curl):
    curl -X POST http://localhost:8000/reports -H "Content-Type: application/json" ^
         -d "{\"clientReportId\":\"abc-123\",\"title\":\"Lampu padam\",\"category\":\"Lampu & Listrik\",\"description\":\"Lab 2 gelap\",\"priority\":\"Tinggi\"}"
"""

import argparse
import json
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

LAPORAN = {}          # clientReportId -> dict
URUTAN_SERVER_ID = {}  # clientReportId -> serverId
COUNTER = {"server_id": 0}
MODE = {"fail": False}


def _kirim(handler, kode, data):
    body = json.dumps(data).encode("utf-8")
    handler.send_response(kode)
    handler.send_header("Content-Type", "application/json; charset=utf-8")
    handler.send_header("Content-Length", str(len(body)))
    handler.end_headers()
    handler.wfile.write(body)


class Handler(BaseHTTPRequestHandler):
    server_version = "CampusReportDemo/1.0"

    def log_message(self, fmt, *args):  # log ringkas
        print("[api]", fmt % args)

    def do_GET(self):
        if self.path == "/health":
            return _kirim(self, 200, {"ok": True, "jumlah": len(LAPORAN)})
        if self.path == "/reports":
            return _kirim(self, 200, {"items": list(LAPORAN.values())})
        return _kirim(self, 404, {"error": "endpoint tidak ada"})

    def do_POST(self):
        if self.path == "/reset":
            LAPORAN.clear()
            URUTAN_SERVER_ID.clear()
            COUNTER["server_id"] = 0
            MODE["fail"] = False
            return _kirim(self, 200, {"ok": True, "pesan": "data dikosongkan"})

        if self.path == "/mode":
            try:
                panjang = int(self.headers.get("Content-Length", 0))
                data = json.loads(self.rfile.read(panjang) or b"{}")
                MODE["fail"] = bool(data.get("fail", False))
            except Exception:
                MODE["fail"] = not MODE["fail"]
            return _kirim(self, 200, {"fail": MODE["fail"]})

        if self.path != "/reports":
            return _kirim(self, 404, {"error": "endpoint tidak ada"})

        # --- simulasi server bermasalah ---
        if MODE["fail"]:
            return _kirim(self, 500, {"error": "server sedang bermasalah (mode demo)"})

        try:
            panjang = int(self.headers.get("Content-Length", 0))
            data = json.loads(self.rfile.read(panjang) or b"{}")
        except Exception:
            return _kirim(self, 400, {"error": "body bukan JSON valid"})

        # --- validasi kontrak (slide P4) ---
        client_id = (data.get("clientReportId") or "").strip()
        judul = (data.get("title") or "").strip()
        kategori = (data.get("category") or "").strip()
        deskripsi = (data.get("description") or "").strip()
        if not client_id:
            return _kirim(self, 400, {"error": "clientReportId wajib ada"})
        if not judul or not kategori or not deskripsi:
            return _kirim(self, 400,
                          {"error": "title, category, description wajib diisi"})

        # --- idempotensi: clientReportId sama -> serverId sama ---
        if client_id in LAPORAN:
            return _kirim(self, 200, {
                "serverId": URUTAN_SERVER_ID[client_id],
                "created": False,
                "pesan": "clientReportId sudah pernah diterima (tidak diduplikasi)",
                "jumlah": len(LAPORAN),
            })

        COUNTER["server_id"] += 1
        server_id = COUNTER["server_id"]
        LAPORAN[client_id] = {
            "serverId": server_id,
            "clientReportId": client_id,
            "title": judul,
            "category": kategori,
            "description": deskripsi,
            "priority": data.get("priority", "Sedang"),
            "createdAt": data.get("createdAt",
                                  datetime.now(timezone.utc).isoformat()),
            "latitude": data.get("latitude"),
            "longitude": data.get("longitude"),
            "receivedAt": datetime.now(timezone.utc).isoformat(),
        }
        URUTAN_SERVER_ID[client_id] = server_id
        return _kirim(self, 201, {"serverId": server_id, "created": True,
                                  "jumlah": len(LAPORAN)})


def main():
    parser = argparse.ArgumentParser(description="Backend demo Campus Report")
    parser.add_argument("--port", type=int, default=8000)
    parser.add_argument("--host", default="0.0.0.0")
    args = parser.parse_args()

    server = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f"Backend demo jalan di http://{args.host}:{args.port}")
    print("  emulator Android -> http://10.0.2.2:%d" % args.port)
    print("  HP fisik        -> http://<IP-komputer>:%d (satu jaringan Wi-Fi)" % args.port)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServer dihentikan.")


if __name__ == "__main__":
    main()
