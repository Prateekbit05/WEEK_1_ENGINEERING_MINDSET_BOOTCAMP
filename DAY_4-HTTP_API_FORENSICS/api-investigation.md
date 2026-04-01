# 📡 API INVESTIGATION — DAY 4 HTTP/API FORENSICS

## Overview
This document analyzes the HTTP request-response cycle using `curl`, Postman, and a custom Node.js server. It covers pagination, headers inspection, ETag caching, and DNS forensics on `dummyjson.com`.

---

## 1. 🔍 DNS Lookup & Traceroute

### curl Commands
```bash
nslookup dummyjson.com
traceroute dummyjson.com
```

**Output:**
```
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   dummyjson.com
Address: 172.67.170.101
Address: 104.21.43.15
```

**Analysis:**
- `dummyjson.com` resolves to Cloudflare IPs (`172.67.x.x`, `104.21.x.x`)
- Low hop count confirms CDN edge routing
- TTL response confirms global Cloudflare distribution

---

## 2. 📄 Pagination Analysis

### curl Command
```bash
curl -v "https://dummyjson.com/products?limit=5&skip=10"
```

### Postman Steps
1. Open Postman → New Request
2. Method: `GET`
3. URL: `https://dummyjson.com/products`
4. Click **Params** tab and add:

| KEY | VALUE |
|-----|-------|
| `limit` | `5` |
| `skip` | `10` |

5. Click **Send**
6. 📸 Take screenshot of response

### Pagination Analysis Table

| Parameter | Value | Description |
|-----------|-------|-------------|
| `limit` | 5 | Number of items per page |
| `skip` | 10 | Number of items to skip |
| `total` | 194 | Total available products |
| Pages available | 39 | total / limit = 194 / 5 |

**Key Takeaway:**
> The API uses **offset-based pagination** via `limit` and `skip` query params. To get page 3: `skip = (page-1) * limit = 2 * 5 = 10`.

---

## 3. 🔧 Header Modification Analysis

### 3a. Remove User-Agent

**curl Command:**
```bash
curl -v -H "User-Agent:" "https://dummyjson.com/products/1"
```

**Postman Steps:**
1. Method: `GET`
2. URL: `https://dummyjson.com/products/1`
3. Click **Headers** tab
4. Add header:

| KEY | VALUE |
|-----|-------|
| `User-Agent` | _(leave empty)_ |

5. Uncheck default Postman `User-Agent` header
6. Click **Send**
7. 📸 Screenshot showing `200 OK`

**Observation:** Server responded with `200 OK` — `dummyjson.com` does not enforce User-Agent validation.

---

### 3b. Send Fake Authorization Header

**curl Command:**
```bash
curl -v -H "Authorization: Bearer fake-token-12345" "https://dummyjson.com/products/1"
```

**Postman Steps:**
1. Method: `GET`
2. URL: `https://dummyjson.com/products/1`
3. Click **Headers** tab
4. Add header:

| KEY | VALUE |
|-----|-------|
| `Authorization` | `Bearer fake-token-12345` |

5. Click **Send**
6. 📸 Screenshot showing `200 OK`

**Observation:** Server responded with `200 OK` — public endpoints ignore Authorization header.

### Header Differences Table

| Header | With User-Agent | Without User-Agent | Fake Auth |
|--------|----------------|-------------------|-----------|
| Status | 200 OK | 200 OK | 200 OK |
| Response | Full JSON | Full JSON | Full JSON |
| Blocked | No | No | No |

**Key Takeaway:**
> Public APIs don't enforce strict header validation. In production APIs, missing or invalid headers typically return `401 Unauthorized` or `403 Forbidden`.

---

## 4. 💾 ETag Caching Analysis

### Step 1: First Request — Get ETag

**curl Command:**
```bash
curl -v "https://dummyjson.com/products/1"
```

**Postman Steps:**
1. Method: `GET`
2. URL: `https://dummyjson.com/products/1`
3. Click **Send**
4. Check **Headers** tab in response → copy `etag` value
5. 📸 Screenshot of response headers showing ETag

**Response Headers:**
```
HTTP/2 200
etag: "abc123xyz"
cache-control: public, max-age=3600
```

---

### Step 2: Re-send with If-None-Match

**curl Command:**
```bash
curl -v -H 'If-None-Match: "abc123xyz"' "https://dummyjson.com/products/1"
```

**Postman Steps:**
1. Method: `GET`
2. URL: `https://dummyjson.com/products/1`
3. Click **Headers** tab → add:

| KEY | VALUE |
|-----|-------|
| `If-None-Match` | `"paste-etag-value-here"` |

4. Click **Send**
5. 📸 Screenshot showing `304 Not Modified`

**Response:**
```
HTTP/2 304 Not Modified
(No response body — cached version used)
```

### ETag Caching Flow

```
Client                          Server
  |                               |
  |-- GET /products/1 ---------->|
  |<-- 200 OK + ETag: "abc123" --|
  |                               |
  |-- GET /products/1             |
  |   If-None-Match: "abc123" -->|
  |<-- 304 Not Modified ----------|
  |   (no body sent)              |
```

### Caching Analysis Table

| Request | Status | Body Sent | Bandwidth Saved |
|---------|--------|-----------|-----------------|
| First request | 200 OK | Yes | No |
| With If-None-Match | 304 Not Modified | No | ✅ Yes |

**Key Takeaway:**
> ETag caching reduces bandwidth by returning `304 Not Modified` when content hasn't changed.

---

## 5. 🖥️ Node HTTP Server Endpoints

### Start Server
```bash
node server.js
```

### /echo — Returns Request Headers

**curl Command:**
```bash
curl http://localhost:3000/echo
```

**Postman Steps:**
1. Method: `GET` → URL: `http://localhost:3000/echo`
2. Click **Send**
3. 📸 Screenshot of response body showing headers

---

### /slow?ms=3000 — Delayed Response

**curl Command:**
```bash
curl "http://localhost:3000/slow?ms=3000"
```

**Postman Steps:**
1. Method: `GET` → URL: `http://localhost:3000/slow`
2. **Params** tab → add `ms` = `3000`
3. Click **Send** — wait 3 seconds
4. 📸 Screenshot showing delayed response

---

### /cache — Returns Cache Headers

**curl Command:**
```bash
curl -v http://localhost:3000/cache
```

**Postman Steps:**
1. Method: `GET` → URL: `http://localhost:3000/cache`
2. Click **Send**
3. Check **Headers** tab in response
4. 📸 Screenshot showing cache headers

---

## 6. 📸 Postman Screenshots Checklist

| Screenshot | Endpoint | What to Capture |
|------------|----------|-----------------|
| `postman-pagination.png` | `/products?limit=5&skip=10` | Response body with total, skip, limit |
| `postman-no-useragent.png` | `/products/1` | No User-Agent header, 200 OK |
| `postman-fake-auth.png` | `/products/1` | Fake Bearer token, 200 OK |
| `postman-etag-first.png` | `/products/1` | Response headers showing ETag |
| `postman-etag-304.png` | `/products/1` | If-None-Match sent, 304 Not Modified |
| `postman-echo.png` | `/echo` | Response body showing request headers |
| `postman-slow.png` | `/slow?ms=3000` | Response after 3s delay |
| `postman-cache.png` | `/cache` | Response headers showing cache headers |

---

## 7. 📊 Summary Analysis

| Topic | Finding |
|-------|---------|
| DNS | dummyjson.com hosted on Cloudflare CDN |
| Pagination | Offset-based using limit + skip params |
| User-Agent removal | No impact on public API |
| Fake Authorization | Ignored on public endpoints |
| ETag caching | 304 response saves bandwidth |
| /echo endpoint | Mirrors all incoming request headers |
| /slow endpoint | Simulates network latency via query param |
| /cache endpoint | Demonstrates cache header implementation |

---

## 🔑 Key Takeaways

1. **Pagination** — Always check `total`, `limit`, `skip` to calculate pages correctly
2. **Headers** — Production APIs enforce strict header validation unlike public test APIs
3. **ETag Caching** — Critical for performance optimization in real applications
4. **DNS** — CDN providers like Cloudflare use multiple IPs for load balancing
5. **Request-Response Cycle** — Every HTTP interaction involves negotiation of headers, status codes and body
