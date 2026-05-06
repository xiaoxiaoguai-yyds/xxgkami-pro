/**
 * 卡密核销接口 /v1/use_card 多语言调用示例
 * 请将 BASE_URL 换为您的 API 根路径（含 /api，勿以 / 结尾），如 https://a.com/api 或 http://localhost:8080/api
 */

export const API_USE_CARD_INTRO = `说明：
· 接口路径：{BASE_URL}/v1/use_card（与文档一致，支持 GET 查询参数或 POST JSON）
· 必填参数：api_key、card_key；可选：machine_code（一机一码）、ip_address（不传则服务端取请求 IP）
· 若 API Key 开启「卡密加密」，card_key 需传加密后的字符串（与开放平台约定一致）`

export const API_USE_CARD_EXAMPLES = [
  {
    id: 'curl',
    label: 'cURL (GET)',
    code: `# GET 查询参数
curl -G "${'BASE_URL'}/v1/use_card" \\
  --data-urlencode "api_key=YOUR_API_KEY" \\
  --data-urlencode "card_key=YOUR_CARD_KEY" \\
  --data-urlencode "machine_code=YOUR_MACHINE_CODE"

# POST JSON
curl -X POST "${'BASE_URL'}/v1/use_card" \\
  -H "Content-Type: application/json" \\
  -d '{"api_key":"YOUR_API_KEY","card_key":"YOUR_CARD_KEY","machine_code":"YOUR_MACHINE_CODE"}'`
  },
  {
    id: 'curl-post-form',
    label: 'cURL (POST 表单)',
    code: `curl -X POST "${'BASE_URL'}/v1/use_card" \\
  -H "Content-Type: application/x-www-form-urlencoded" \\
  --data "api_key=YOUR_API_KEY&card_key=YOUR_CARD_KEY&machine_code=YOUR_MACHINE_CODE"`
  },
  {
    id: 'wget',
    label: 'Wget',
    code: `wget -qO- "${'BASE_URL'}/v1/use_card?api_key=YOUR_API_KEY&card_key=YOUR_CARD_KEY&machine_code=YOUR_MACHINE_CODE"`
  },
  {
    id: 'httpie',
    label: 'HTTPie',
    code: `# GET
http GET "${'BASE_URL'}/v1/use_card" api_key==YOUR_API_KEY card_key==YOUR_CARD_KEY machine_code==YOUR_MACHINE_CODE

# POST JSON
http POST "${'BASE_URL'}/v1/use_card" api_key=YOUR_API_KEY card_key=YOUR_CARD_KEY machine_code=YOUR_MACHINE_CODE`
  },
  {
    id: 'powershell',
    label: 'PowerShell',
    code: `$base = "BASE_URL"
$uri = "$base/v1/use_card?api_key=YOUR_API_KEY&card_key=YOUR_CARD_KEY&machine_code=YOUR_MACHINE_CODE"
Invoke-RestMethod -Uri $uri -Method Get

# POST JSON
$body = @{
  api_key = "YOUR_API_KEY"
  card_key = "YOUR_CARD_KEY"
  machine_code = "YOUR_MACHINE_CODE"
} | ConvertTo-Json
Invoke-RestMethod -Uri "$base/v1/use_card" -Method Post -Body $body -ContentType "application/json"`
  },
  {
    id: 'node-fetch',
    label: 'Node.js (fetch)',
    code: `const BASE = process.env.API_BASE || 'BASE_URL';

async function useCard() {
  const url = new URL(BASE + '/v1/use_card');
  url.searchParams.set('api_key', 'YOUR_API_KEY');
  url.searchParams.set('card_key', 'YOUR_CARD_KEY');
  url.searchParams.set('machine_code', 'YOUR_MACHINE_CODE');
  const res = await fetch(url);
  const data = await res.json();
  console.log(data);
}

async function useCardPost() {
  const res = await fetch(BASE + '/v1/use_card', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      api_key: 'YOUR_API_KEY',
      card_key: 'YOUR_CARD_KEY',
      machine_code: 'YOUR_MACHINE_CODE'
    })
  });
  console.log(await res.json());
}

useCard().catch(console.error);`
  },
  {
    id: 'node-axios',
    label: 'Node.js (axios)',
    code: `const axios = require('axios');
const BASE = process.env.API_BASE || 'BASE_URL';

axios.get(BASE + '/v1/use_card', {
  params: {
    api_key: 'YOUR_API_KEY',
    card_key: 'YOUR_CARD_KEY',
    machine_code: 'YOUR_MACHINE_CODE'
  }
}).then(r => console.log(r.data)).catch(console.error);

axios.post(BASE + '/v1/use_card', {
  api_key: 'YOUR_API_KEY',
  card_key: 'YOUR_CARD_KEY',
  machine_code: 'YOUR_MACHINE_CODE'
}).then(r => console.log(r.data)).catch(console.error);`
  },
  {
    id: 'browser-js',
    label: '浏览器 JavaScript',
    code: `const BASE = 'BASE_URL';

async function redeem() {
  const u = new URL(BASE + '/v1/use_card');
  u.searchParams.set('api_key', 'YOUR_API_KEY');
  u.searchParams.set('card_key', 'YOUR_CARD_KEY');
  const r = await fetch(u.toString(), { method: 'GET' });
  return r.json();
}

redeem().then(console.log).catch(console.error);`
  },
  {
    id: 'html',
    label: 'HTML + fetch',
    code: `<!DOCTYPE html>
<html><body>
<button id="go">核销</button>
<pre id="out"></pre>
<script>
const BASE = 'BASE_URL';
document.getElementById('go').onclick = async () => {
  const u = new URL(BASE + '/v1/use_card');
  u.searchParams.set('api_key', 'YOUR_API_KEY');
  u.searchParams.set('card_key', document.querySelector('#card').value);
  const r = await fetch(u);
  document.getElementById('out').textContent = JSON.stringify(await r.json(), null, 2);
};
</script>
<input id="card" placeholder="卡密" />
</body></html>`
  },
  {
    id: 'vue3',
    label: 'Vue 3',
    code: `<script setup>
import { ref } from 'vue'
const BASE = 'BASE_URL'
const result = ref(null)
const loading = ref(false)
const cardKey = ref('')

async function redeem() {
  loading.value = true
  try {
    const u = new URL(BASE + '/v1/use_card')
    u.searchParams.set('api_key', 'YOUR_API_KEY')
    u.searchParams.set('card_key', cardKey.value)
    const r = await fetch(u.toString())
    result.value = await r.json()
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div>
    <input v-model="cardKey" placeholder="卡密" />
    <button :disabled="loading" @click="redeem">核销</button>
    <pre>{{ result }}</pre>
  </div>
</template>`
  },
  {
    id: 'python-requests',
    label: 'Python (requests)',
    code: `import requests

BASE = "BASE_URL"

# GET
r = requests.get(f"{BASE}/v1/use_card", params={
    "api_key": "YOUR_API_KEY",
    "card_key": "YOUR_CARD_KEY",
    "machine_code": "YOUR_MACHINE_CODE",
})
print(r.json())

# POST JSON
r = requests.post(
    f"{BASE}/v1/use_card",
    json={
        "api_key": "YOUR_API_KEY",
        "card_key": "YOUR_CARD_KEY",
        "machine_code": "YOUR_MACHINE_CODE",
    },
)
print(r.json())`
  },
  {
    id: 'python-urllib',
    label: 'Python (urllib)',
    code: `import json
import urllib.parse
import urllib.request

BASE = "BASE_URL"

def get_redeem():
    q = urllib.parse.urlencode({
        "api_key": "YOUR_API_KEY",
        "card_key": "YOUR_CARD_KEY",
        "machine_code": "YOUR_MACHINE_CODE",
    })
    url = f"{BASE}/v1/use_card?{q}"
    with urllib.request.urlopen(url) as resp:
        return json.loads(resp.read().decode())

def post_redeem():
    data = json.dumps({
        "api_key": "YOUR_API_KEY",
        "card_key": "YOUR_CARD_KEY",
        "machine_code": "YOUR_MACHINE_CODE",
    }).encode()
    req = urllib.request.Request(
        f"{BASE}/v1/use_card",
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode())

print(get_redeem())`
  },
  {
    id: 'php',
    label: 'PHP',
    code: `<?php
$base = 'BASE_URL';
$url = $base . '/v1/use_card?' . http_build_query([
    'api_key' => 'YOUR_API_KEY',
    'card_key' => 'YOUR_CARD_KEY',
    'machine_code' => 'YOUR_MACHINE_CODE',
]);
$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
echo curl_exec($ch);

// POST JSON
$ch = curl_init($base . '/v1/use_card');
curl_setopt_array($ch, [
    CURLOPT_POST => true,
    CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
    CURLOPT_POSTFIELDS => json_encode([
        'api_key' => 'YOUR_API_KEY',
        'card_key' => 'YOUR_CARD_KEY',
        'machine_code' => 'YOUR_MACHINE_CODE',
    ]),
    CURLOPT_RETURNTRANSFER => true,
]);
echo curl_exec($ch);`
  },
  {
    id: 'go',
    label: 'Go',
    code: `package main

import (
    "encoding/json"
    "fmt"
    "io"
    "net/http"
    "net/url"
    "strings"
)

const base = "BASE_URL"

func main() {
    u, _ := url.Parse(base + "/v1/use_card")
    q := u.Query()
    q.Set("api_key", "YOUR_API_KEY")
    q.Set("card_key", "YOUR_CARD_KEY")
    q.Set("machine_code", "YOUR_MACHINE_CODE")
    u.RawQuery = q.Encode()
    resp, err := http.Get(u.String())
    if err != nil {
        panic(err)
    }
    defer resp.Body.Close()
    body, _ := io.ReadAll(resp.Body)
    fmt.Println(string(body))

    // POST JSON
    payload := "{\"api_key\":\"YOUR_API_KEY\",\"card_key\":\"YOUR_CARD_KEY\",\"machine_code\":\"YOUR_MACHINE_CODE\"}"
    resp2, err := http.Post(base+"/v1/use_card", "application/json", strings.NewReader(payload))
    if err != nil {
        panic(err)
    }
    defer resp2.Body.Close()
    var v map[string]interface{}
    json.NewDecoder(resp2.Body).Decode(&v)
    fmt.Println(v)
}`
  },
  {
    id: 'java',
    label: 'Java (HttpClient)',
    code: `import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

public class UseCard {
    static final String BASE = "BASE_URL";

    public static void main(String[] args) throws Exception {
        var client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
        String q = "api_key=" + enc("YOUR_API_KEY")
            + "&card_key=" + enc("YOUR_CARD_KEY")
            + "&machine_code=" + enc("YOUR_MACHINE_CODE");
        var getReq = HttpRequest.newBuilder()
            .uri(URI.create(BASE + "/v1/use_card?" + q))
            .GET().build();
        System.out.println(client.send(getReq, HttpResponse.BodyHandlers.ofString()).body());

        String json = "{\\"api_key\\":\\"YOUR_API_KEY\\",\\"card_key\\":\\"YOUR_CARD_KEY\\",\\"machine_code\\":\\"YOUR_MACHINE_CODE\\"}";
        var postReq = HttpRequest.newBuilder()
            .uri(URI.create(BASE + "/v1/use_card"))
            .header("Content-Type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString(json))
            .build();
        System.out.println(client.send(postReq, HttpResponse.BodyHandlers.ofString()).body());
    }
    static String enc(String s) { return URLEncoder.encode(s, StandardCharsets.UTF_8); }
}`
  },
  {
    id: 'csharp',
    label: 'C# (.NET)',
    code: `using System.Net.Http;
using System.Text;
using System.Text.Json;

const string Base = "BASE_URL";

using var http = new HttpClient();
var qs = "api_key=YOUR_API_KEY&card_key=YOUR_CARD_KEY&machine_code=YOUR_MACHINE_CODE";
var getResp = await http.GetAsync($"{Base}/v1/use_card?{qs}");
Console.WriteLine(await getResp.Content.ReadAsStringAsync());

var body = JsonSerializer.Serialize(new {
    api_key = "YOUR_API_KEY",
    card_key = "YOUR_CARD_KEY",
    machine_code = "YOUR_MACHINE_CODE"
});
var postResp = await http.PostAsync($"{Base}/v1/use_card",
    new StringContent(body, Encoding.UTF8, "application/json"));
Console.WriteLine(await postResp.Content.ReadAsStringAsync());`
  },
  {
    id: 'ruby',
    label: 'Ruby',
    code: `require 'net/http'
require 'json'
require 'uri'

BASE = 'BASE_URL'

uri = URI("#{BASE}/v1/use_card")
uri.query = URI.encode_www_form(
  api_key: 'YOUR_API_KEY',
  card_key: 'YOUR_CARD_KEY',
  machine_code: 'YOUR_MACHINE_CODE'
)
puts Net::HTTP.get(uri)

uri2 = URI("#{BASE}/v1/use_card")
req = Net::HTTP::Post.new(uri2)
req['Content-Type'] = 'application/json'
req.body = {
  api_key: 'YOUR_API_KEY',
  card_key: 'YOUR_CARD_KEY',
  machine_code: 'YOUR_MACHINE_CODE'
}.to_json
puts Net::HTTP.start(uri2.hostname, uri2.port, use_ssl: uri2.scheme == 'https') { |h| h.request(req).body }`
  },
  {
    id: 'kotlin',
    label: 'Kotlin',
    code: `import java.net.HttpURLConnection
import java.net.URL

fun main() {
    val base = "BASE_URL"
    val q = "api_key=YOUR_API_KEY&card_key=YOUR_CARD_KEY&machine_code=YOUR_MACHINE_CODE"
    val conn = URL("$base/v1/use_card?$q").openConnection() as HttpURLConnection
    println(conn.inputStream.bufferedReader().readText())
}`
  },
  {
    id: 'dart',
    label: 'Dart (Flutter)',
    code: `import 'dart:convert';
import 'package:http/http.dart' as http;

const base = 'BASE_URL';

Future<void> main() async {
  final uri = Uri.parse('$base/v1/use_card').replace(queryParameters: {
    'api_key': 'YOUR_API_KEY',
    'card_key': 'YOUR_CARD_KEY',
    'machine_code': 'YOUR_MACHINE_CODE',
  });
  print(await http.read(uri));

  final r = await http.post(
    Uri.parse('$base/v1/use_card'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'api_key': 'YOUR_API_KEY',
      'card_key': 'YOUR_CARD_KEY',
      'machine_code': 'YOUR_MACHINE_CODE',
    }),
  );
  print(r.body);
}`
  },
  {
    id: 'rust',
    label: 'Rust (reqwest)',
    code: `#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let base = "BASE_URL";
    let client = reqwest::Client::new();
    let get_url = format!(
        "{}/v1/use_card?api_key={}&card_key={}&machine_code={}",
        base,
        "YOUR_API_KEY",
        "YOUR_CARD_KEY",
        "YOUR_MACHINE_CODE"
    );
    let r = client.get(&get_url).send().await?;
    println!("{}", r.text().await?);

    let r2 = client
        .post(format!("{}/v1/use_card", base))
        .json(&serde_json::json!({
            "api_key": "YOUR_API_KEY",
            "card_key": "YOUR_CARD_KEY",
            "machine_code": "YOUR_MACHINE_CODE",
        }))
        .send()
        .await?;
    println!("{}", r2.text().await?);
    Ok(())
}`
  },
  {
    id: 'swift',
    label: 'Swift',
    code: `import Foundation

let base = "BASE_URL"
var comp = URLComponents(string: base + "/v1/use_card")!
comp.queryItems = [
    URLQueryItem(name: "api_key", value: "YOUR_API_KEY"),
    URLQueryItem(name: "card_key", value: "YOUR_CARD_KEY"),
    URLQueryItem(name: "machine_code", value: "YOUR_MACHINE_CODE"),
]
let (data, _) = try await URLSession.shared.data(from: comp.url!)
print(String(data: data, encoding: .utf8)!)

// POST JSON
var req = URLRequest(url: URL(string: base + "/v1/use_card")!)
req.httpMethod = "POST"
req.setValue("application/json", forHTTPHeaderField: "Content-Type")
req.httpBody = try JSONSerialization.data(withJSONObject: [
    "api_key": "YOUR_API_KEY",
    "card_key": "YOUR_CARD_KEY",
    "machine_code": "YOUR_MACHINE_CODE",
])`
  }
]
