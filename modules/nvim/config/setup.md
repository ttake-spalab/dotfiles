# Neovim Setup & Cleanup Guide

Neovimのインストールおよび完全削除の手順である。

## Ubuntu

### 1. 前提条件 (Prerequisites)

一部のプラグイン（LSP管理等）を動作させるため、システムに `node` と `npm` が必要となる。

```bash
sudo apt update && sudo apt install -y nodejs npm
```

#### 2. インストール手順 (Installations)

#### パターンA: AppImage方式（推奨）
```bash
mkdir -p ~/.local/bin
curl -LO [https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage](https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage)
chmod u+x nvim-linux-x86_64.appimage
mv nvim-linux-x86_64.appimage ~/.local/bin/nvim
```

#### パターンB: tar.gz方式（AppImageが動作しない場合）
```bash
curl -LO [https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz](https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz)
tar -C ~/.local --strip-components=1 -xzf nvim-linux-x86_64.tar.gz
rm nvim-linux-x86_64.tar.gz
```

### 3. Python LSPのセットアップ (Python LSP setup)

Python 環境においてLSP (Language Server Protocol) や静的解析ツールを動作させる。
`uv` を用いて、必要なツールをグローバルにインストールした。

```bash
uv tool install ruff ty
```

### 4. 完全アンインストール手順 (Uninstallation & Cleanup)

本体および自動生成された関連データをシステムから完全に削除するコマンドである。

```bash
# 本体（バイナリ）の削除
rm -f ~/.local/bin/nvim

# 関連ディレクトリの完全削除
rm -rf ~/.config/nvim       # 設定ファイル（このフォルダ自身）
rm -rf ~/.local/share/nvim  # プラグイン・LSPの実体
rm -rf ~/.local/state/nvim  # 編集履歴・ログ
rm -rf ~/.cache/nvim        # キャッシュ
```

## Mac

```bash
brew install neovim
```

## macOS

### 1. インストール手順 (Installations)

#### パターンA: Homebrew方式（推奨）

```bash
brew install neovim
```

#### パターンB: tar.gz方式（バイナリを直接配置する場合）

Homebrew を利用しない手順。
Intel Macの場合は `arm64` を `x86_64` に適宜読み替えること。

```bash
mkdir -p ~/.local/bin
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-macos-arm64.tar.gz
tar -C ~/.local --strip-components=1 -xzf nvim-macos-arm64.tar.gz
rm nvim-macos-arm64.tar.gz
```

### 3. Python環境・LSPのセットアップ (Python LSP Setup)

Python環境においてLSP（Language Server Protocol）や静的解析ツールを動作させる。
パッケージマネージャー `uv` を使用し、ツールをグローバルにインストールする。

```bash
# ruff および ty のインストール
uv tool install ruff ty
```

### 4. 完全アンインストール手順 (Uninstallation & Cleanup)

本体および自動生成された関連データをシステムから完全に削除するコマンドである。

```bash
# 本体の削除
brew uninstall neovim    # Homebrewでインストールした場合
rm -f ~/.local/bin/nvim  # バイナリを手動配置した場合

# 関連ディレクトリの完全削除
rm -rf ~/.config/nvim       # 設定ファイル（このフォルダ自身）
rm -rf ~/.local/share/nvim  # プラグイン・LSPの実体
rm -rf ~/.local/state/nvim  # 編集履歴・ログ
rm -rf ~/.cache/nvim        # キャッシュ
```
