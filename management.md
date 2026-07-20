# Nix + Home Manager による Dotfiles 管理設計

## 1. 設計目標

本設計は、NixとHome Managerを用いて複数マシンの開発環境を長期間保守することを目的とする。

目標は次の5点である。

1. 新しいマシンでは、`install.sh`一つで環境構築が完了すること。
2. 設定はGitHubで一元管理し、どのマシンでも同じ手順で再現できること。
3. Mac、Linuxなど複数OSや複数マシンへ容易に拡張できること。
4. 将来的に設定量が増えても、設計そのものは変更せず整理だけで対応できること。
5. 「最初は小さく始め、必要になったら自然に拡張できる」こと。

本資料では、初期構成と、その後の拡張計画を一つの設計としてまとめる。

---

## 2. 設計思想

本設計では、設定を「何を書くか」ではなく「何を担当するか」で分離する。

最終的に存在する責務は次の4層のみである。

```text
install.sh
    ↓
mkHost
    ↓
Profile
    ↓
Module
```

この4層は設計の根幹であり、リポジトリが大きくなっても変更しない。

各層の責務は次のように定義する。

| 層          | 責務                       |
| ---------- | ------------------------ |
| install.sh | Nix導入・dotfiles取得・flake適用 |
| mkHost     | HostとProfileを合成する        |
| Profile    | 利用目的に応じてModuleを組み合わせる    |
| Module     | 個々の機能を提供する               |

重要なのは、それぞれの責務を混在させないことである。

---

## 3. install.sh の責務

install.shは唯一のブートストラップである。
責務は以下のみとする。

* Nixが存在しなければインストールする
* dotfilesをcloneまたは更新する
* Roleを保存または読み込む
* flakeを適用する

逆に、次のような処理は持たせない。

* 設定ファイルのコピー
* シンボリックリンク作成
* Home Managerの設定内容
* ホストごとの条件分岐

環境構築のロジックはすべてflake側に委譲する。

---

## 4. mkHost の責務

mkHostは唯一の「組み立て場所」である。
概念的には次の処理だけを行う。

```text
Host
    +
Profile
    +
Common
        ↓
Home Manager Configuration
```

つまり、

* Host固有設定
* 利用目的(Profile)
* 共通設定(Common)

を合成し、最終的なHome Manager Configurationを生成する。

HostやProfileが増えても、この関数だけは変更しないことを目標とする。

---

## 5. Host の責務

Hostは「物理マシン固有の情報」のみを保持する。

例えば次のような内容である。

* hostname
* system
* username
* GUI固有設定
* モニタ設定
* Dock設定
* Touch ID設定

逆に、次のような設定はHostへ書かない。

* Git
* Zsh
* Neovim
* Rust
* Python
* Docker

これらは利用目的に依存するためProfileまたはModuleへ配置する。

Hostは設定ではなく「データ」と考える。

---

## 6. Profile の責務

Profileは「用途」を表現する。

例えば、

* workstation
* laptop
* server
* minimal

などである。

Profile自身はModuleを組み合わせるだけであり、実装を持たない。

例えば、

```
workstation
↓
Git
Zsh
Neovim
Rust
Python
Docker
```

という組み合わせを定義する。

Profileは「何をしたいか」を表現し、「どう設定するか」はModuleへ委譲する。

---

## 7. Module の責務

Moduleは最小単位の機能である。

例えば、

* Git
* Shell
* Neovim
* Rust
* Python

などがModuleになる。

Moduleはできる限り一つの責務だけを持つ。

例えばGit Moduleであれば、

* Git本体
* Delta
* Git LFS
* Signing
* Alias

などGitに関することだけを担当する。

ProfileやHostの知識は持たせない。

---

## 8. 初期構成

最初は一台しかPCがなくても構わない。

その場合でも最終形と同じ責務で開始する。

```
dotfiles/
├── flake.nix
├── install.sh
├── lib/
│   └── mkHost.nix
├── hosts/
│   └── mac-mini.nix
├── profiles/
│   └── default.nix
└── modules/
    ├── git.nix
    ├── shell.nix
    └── nvim.nix
```

この構成なら、将来の拡張時もディレクトリ構成を変更する必要がない。

---

## 9. 拡張計画

### Step 1

Hostは一台。
Profileも一つ。

```
Host
    ↓
Default
    ↓
Git
Shell
Neovim
```

### Step 2

Moduleを追加する。

```
modules/
  git.nix
  shell.nix
  nvim.nix
  tmux.nix
  starship.nix
```

構造は変わらない。

### Step 3

Hostが増える。

```
hosts/
  mac-mini.nix
  macbook-air.nix
```

### Step 4

Profileが分かれる。

```
profiles/
  default.nix
  laptop.nix
```

### Step 5

Profileが肥大化したら共通部分を切り出す。

```
profiles/
  common.nix
  workstation.nix
  laptop.nix
  minimal.nix
```

例えばworkstationは、 `common + docker + latex` という組み合わせだけを書く。

### Step 6

Module数が増えたらディレクトリ整理を行う。

```
modules/
  cli/
  desktop/
  development/
  editors/
```

ここではファイルを移動するだけで設計は変わらない。

### Step 7

さらに規模が大きくなったらCapabilityを導入する。

```
Capability
↓
Application
```

例えば、 `Terminal → Ghostty` あるいは、 `Editor → Neovim` のように抽象化する。
ProfileはCapabilityだけを見るため、アプリケーションを変更してもProfileを書き換える必要がない。

## 10. リファクタリングの指針

設計は必要になった時だけ抽象化する。

以下を目安とする。

| 状態                    | リファクタリング              |
| --------------------- | --------------------- |
| modules直下が10〜15個程度    | サブディレクトリへ整理           |
| Profileのimportsが10個程度 | common.nixを導入         |
| Hostが3台以上             | Hostをデータ中心に整理         |
| 同じ条件分岐が3回以上現れる        | Module化またはCapability化 |

重要なのは、「最初から理想形を実装しない」ことである。

必要になった時だけ一段抽象化する。

## 11. 設計原則

このリポジトリでは、以下の原則を守る。

* install.shはブートストラップだけを担当する。
* mkHostだけが設定を組み立てる。
* Hostは物理マシンを表す。
* Profileは利用目的を表す。
* Moduleは機能を表す。
* 一つの責務は一か所だけが持つ。

これらを守る限り、設定量が数十ファイルから数百ファイルへ増えても設計そのものを変更する必要はほとんどない。

## 12. 最終形

数年後には例えば次のような構成へ発展することを想定する。

```
dotfiles/
├── flake.nix
├── install.sh
├── lib/
│   └── mkHost.nix
├── hosts/
│   ├── mac-mini.nix
│   ├── macbook-air.nix
│   └── server.nix
├── profiles/
│   ├── common.nix
│   ├── workstation.nix
│   ├── laptop.nix
│   ├── server.nix
│   └── minimal.nix
└── modules/
    ├── cli/
    ├── desktop/
    ├── development/
    ├── editors/
    ├── capabilities/
    └── applications/
```

この構成は最初の設計から責務を変更していない。
違いは、Moduleが整理され、Profileが増え、Hostが増えただけである。
設計の骨格である `install.sh > mkHost > Profile > Module` は最初から最後まで不変であり、この一貫性が長期保守性を支える最も重要な設計原則となる。
