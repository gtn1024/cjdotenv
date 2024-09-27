<div align="center">
  <h1>CjDotEnv</h1>
  <p>A Cangjie library to load environment variables from <code>.env</code>.</p>
</div>
<p align="center">
  <img alt="" src="https://img.shields.io/badge/release-v0.1.0-brightgreen" style="display: inline-block;" />
  <img alt="" src="https://img.shields.io/badge/cjc-v0.55.3-brightgreen" style="display: inline-block;" />
  <img alt="" src="https://github.com/gtn1024/cjdotenv/actions/workflows/ci.yml/badge.svg" style="display: inline-block;" />
  <img alt="" src="https://wakatime.com/badge/user/e6f96ccc-06db-4ccd-b529-315ffa2a1082/project/b0d15d47-129c-4873-99a3-19750e2c55db.svg" style="display: inline-block;" />
</p>

## 介绍 / Introduction

CjDotEnv is a Cangjie library to load environment variables from `.env` file.

CjDotEnv 是一个用来从 `.env` 文件中加载环境变量的仓颉库。

## 安装 / Installation

```toml
# In the `dependencies` section of `cjpm.toml`
cjdotenv = { git = "https://github.com/gtn1024/cjdotenv.git", tag = "0.1.0" }
```

## 使用 / Usage

```shell
# .env

# Database
DB_HOST=localhost
DB_USER=postgres
DB_PASS=123456
DB_DATABASE=postgres
```

```cj
import cjdotenv.load
import std.os.getEnv

main() {
    load()
    // or
    // load(".env")
    // load("path/to/.env")
    // load("one.env", "two.env", "three.env")

    println(getEnv("DB_HOST"))
    println(getEnv("DB_USER"))
    println(getEnv("DB_PASS"))
    println(getEnv("DB_DATABASE"))
}
```

## QQ 群

欢迎加入 [仓颉交流群（非官方）：985038695](https://qm.qq.com/q/PcRbAUJSo0)

![qqgroup](./.github/qqgroup.jpg)
