# Neovim 세팅 가이드

이 문서는 Neovim을 처음 설치하고 설정하는 전 과정을 설명합니다.

---

## 목차

1. [왜 Neovim인가?](#1-왜-neovim인가)
2. [설치 방법](#2-설치-방법)
3. [디렉토리 구조 이해하기](#3-디렉토리-구조-이해하기)
4. [lazy.nvim 플러그인 매니저](#4-lazynvim-플러그인-매니저)
5. [각 플러그인 설명](#5-각-플러그인-설명)
6. [LSP(clangd)란?](#6-lspclangd란)
7. [처음 실행 시 일어나는 일](#7-처음-실행-시-일어나는-일)
8. [문제 해결](#8-문제-해결)

---

## 1. 왜 Neovim인가?

### Vim과의 차이점
| 항목 | Vim | Neovim |
|------|-----|--------|
| 설정 언어 | VimScript만 가능 | **Lua** (빠르고 현대적) + VimScript 호환 |
| 플러그인 생태계 | 정체됨 | 활발한 Lua 플러그인 생태계 |
| LSP 지원 | 외부 플러그인 필요 | **내장** LSP 클라이언트 |
| 비동기 처리 | 제한적 | 완전한 비동기 지원 |
| 시작 속도 | 보통 | lazy-loading으로 **매우 빠름** |

### 왜 최신 버전이 필요한가?
- 시스템에 설치된 Neovim은 **v0.4.4** (2020년)로 매우 오래됨
- Lua 설정, 내장 LSP, treesitter 등 모던 기능은 **v0.8+** 필요
- 현재 설치한 버전: **v0.10.4** (2024년)

---

## 2. 설치 방법

이미 설치되어 있지만, 향후 업데이트 시 참고용으로 기록합니다.

### 2-1. 다운로드 및 설치 (macOS)

```bash
# Homebrew를 사용한 설치 (ripgrep도 함께 설치)
brew update
brew install neovim ripgrep
```

### 2-2. 다운로드 및 설치 (Linux)

```bash
# GitHub에서 최신 릴리즈 다운로드
curl -L -o /tmp/nvim.tar.gz \
  "https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz"

# ~/.local/ 에 압축 해제
tar xzf /tmp/nvim.tar.gz -C /tmp/
cp -r /tmp/nvim-linux-x86_64/* ~/.local/

# 정리
rm -rf /tmp/nvim-linux-x86_64 /tmp/nvim.tar.gz
```

### 2-3. PATH 설정

`~/.bashrc` 또는 `~/.zshrc`에 다음이 있어야 합니다:

```bash
# Linux의 경우
export PATH="$HOME/.local/bin:$PATH"

# macOS Homebrew의 경우 (보통 자동 설정됨)
```

> **주의:** `$HOME/.local/bin`이 `$PATH` **앞에** 와야 시스템 nvim(v0.4.4) 대신 새 버전이 사용됩니다. (Linux 환경)

### 2-4. 확인

```bash
# 새 셸을 열고 확인
nvim --version
# NVIM v0.10.4 가 나와야 함
```

> **참고:** 기존 `vim` 명령은 그대로 동작합니다. `.vimrc`는 수정하지 않았으므로 Vim은 예전 그대로 사용 가능합니다.

---

## 3. 디렉토리 구조 이해하기

```
~/.config/nvim/               ← Neovim 설정 루트 디렉토리
├── init.lua                  ← 진입점 (Neovim이 시작할 때 가장 먼저 읽는 파일)
├── lua/                      ← Lua 모듈 디렉토리
│   ├── options.lua           ← 기본 에디터 옵션 (줄번호, 탭, 인코딩 등)
│   ├── keymaps.lua           ← 키 매핑 (단축키 설정)
│   ├── plugins.lua           ← 플러그인 목록 및 설정 (lazy.nvim)
│   └── lsp.lua               ← LSP 설정 (clangd 자동완성 등)
├── SETUP_GUIDE.md            ← 이 파일 (세팅 가이드)
└── NEOVIM_MANUAL.md          ← 사용 매뉴얼
```

### 각 파일의 역할

| 파일 | 역할 | Vim에서의 대응 |
|------|------|---------------|
| `init.lua` | 모든 설정의 진입점. 다른 모듈을 `require()`로 로드 | `.vimrc` |
| `options.lua` | `set number`, `set tabstop=4` 같은 기본 설정 | `.vimrc`의 `set` 명령들 |
| `keymaps.lua` | 단축키 정의 (`<leader>ff` → 파일 검색 등) | `.vimrc`의 `nnoremap` 등 |
| `plugins.lua` | 사용할 플러그인 목록과 각 플러그인 설정 | Vundle의 `Plugin '...'` 목록 |
| `lsp.lua` | 언어 서버(clangd) 연결 및 자동완성 설정 | vim-lsp 관련 설정 |

### 왜 파일을 나누는가?
- **가독성:** 한 파일에 모든 걸 넣으면 수백 줄이 되어 관리 어려움
- **모듈성:** 특정 설정만 수정하고 싶을 때 해당 파일만 열면 됨
- **디버깅:** 문제가 생기면 해당 모듈만 주석처리하여 원인 파악 가능

---

## 4. lazy.nvim 플러그인 매니저

### 플러그인 매니저란?
Vim/Neovim은 기본 기능 외에 추가 기능을 **플러그인**으로 확장합니다.
플러그인 매니저는 이런 플러그인들을 **설치, 업데이트, 삭제**하는 도구입니다.

| 세대 | 매니저 | 특징 |
|------|--------|------|
| 1세대 | Vundle (기존) | VimScript, 느림, 관리 불편 |
| 2세대 | vim-plug | 가벼움, 병렬 설치 |
| 3세대 | **lazy.nvim** (현재) | Lua 기반, **lazy-loading**, 최고 속도 |

### lazy.nvim의 동작 원리
1. Neovim 시작 → `plugins.lua` 로드
2. lazy.nvim이 플러그인 목록을 읽음
3. 필요한 플러그인만 그때그때 로드 (lazy-loading)
4. 사용하지 않는 플러그인은 메모리에 올리지 않음 → **빠른 시작**

### lazy.nvim 관리 명령어

| 명령어 | 설명 |
|--------|------|
| `:Lazy` | 플러그인 관리 UI 열기 (설치/업데이트/삭제) |
| `:Lazy sync` | 모든 플러그인 동기화 (설치 + 업데이트) |
| `:Lazy update` | 플러그인 업데이트만 |
| `:Lazy clean` | 사용하지 않는 플러그인 삭제 |
| `:Lazy health` | 플러그인 상태 진단 |

> **팁:** `:Lazy` UI에서 `U`를 누르면 모든 플러그인 업데이트, `q`로 닫기

---

## 5. 각 플러그인 설명

### 기존 Vim 플러그인과의 대응

| 기존 (Vim) | 현재 (Neovim) | 역할 |
|------------|--------------|------|
| NERDTree | **nvim-tree.lua** | 파일 탐색기 |
| vim-airline | **lualine.nvim** | 상태바 |
| vim-gitgutter | **gitsigns.nvim** | git 변경 표시 |
| jellybeans | **tokyonight.nvim** | 컬러스킴 |
| vim-indent-guides | **indent-blankline.nvim** | 들여쓰기 가이드 |
| fzf | **telescope.nvim** | 퍼지 검색 |
| vim-lsp + asyncomplete | **nvim-lspconfig + nvim-cmp** | LSP + 자동완성 |
| - | **nvim-treesitter** | 향상된 구문 강조 |
| - | **Comment.nvim** | 주석 토글 |
| vim-fugitive | **vim-fugitive** | git 명령어 (변경 없음) |

### 각 플러그인 상세

#### telescope.nvim
- **무엇:** 파일 이름, 파일 내용, 버퍼 등을 퍼지 검색하는 도구
- **왜 필요:** HANA 소스처럼 파일이 수만 개인 프로젝트에서 원하는 파일을 빠르게 찾기 위해
- **의존성:** plenary.nvim (유틸리티 라이브러리)

#### nvim-tree.lua
- **무엇:** 화면 왼쪽에 표시되는 파일/디렉토리 트리
- **왜 필요:** 디렉토리 구조를 시각적으로 탐색하고 파일을 열기 위해
- **의존성:** nvim-web-devicons (파일 타입별 아이콘)

#### lualine.nvim
- **무엇:** 화면 하단의 상태바
- **왜 필요:** 현재 모드, 파일명, git 브랜치, 에러 수 등 유용한 정보를 한눈에 보기 위해

#### nvim-lspconfig + nvim-cmp
- **무엇:** LSP 서버 설정 + 자동완성 엔진
- **왜 필요:** C++ 코드에서 정의 이동, 자동완성, 에러 표시 등 IDE 기능을 위해
- **의존성:** cmp-nvim-lsp, cmp-buffer, cmp-path, LuaSnip 등

#### nvim-treesitter
- **무엇:** 코드의 구문 트리(AST)를 분석하는 파서
- **왜 필요:** 정규식 기반보다 훨씬 정확한 구문 강조를 위해
- **참고:** 자동으로 동작하므로 별도 조작 불필요

#### gitsigns.nvim
- **무엇:** 에디터 왼쪽에 git 변경 상태를 실시간 표시
- **왜 필요:** 어떤 줄이 추가/수정/삭제되었는지 코딩 중에 바로 확인하기 위해

#### Comment.nvim
- **무엇:** 코드 주석을 쉽게 토글하는 도구
- **왜 필요:** `gcc` 한 번으로 줄 주석 on/off. 범위 선택 후 `gc`로 블록 주석

#### indent-blankline.nvim
- **무엇:** 들여쓰기 레벨마다 세로 가이드라인 표시
- **왜 필요:** 깊은 중첩에서 코드 블록의 시작/끝을 시각적으로 파악

---

## 6. LSP(clangd)란?

### LSP(Language Server Protocol)
```
┌──────────┐     LSP 프로토콜     ┌──────────────┐
│  Neovim  │ ←────────────────→ │   clangd     │
│ (에디터) │   JSON-RPC 통신    │ (언어 서버)  │
└──────────┘                    └──────────────┘
```

- **에디터(클라이언트):** Neovim이 사용자 입력을 받아 언어 서버에 요청
- **언어 서버:** 코드를 분석하여 자동완성, 정의 위치, 에러 등을 응답
- **프로토콜:** 둘 사이의 통신 규격 (어떤 에디터든, 어떤 언어든 같은 방식)

### clangd
- LLVM/Clang 프로젝트에서 만든 C/C++ 전용 언어 서버
- 현재 시스템에 설치된 버전: **clangd 15.0.7** (`/usr/bin/clangd`)
- HANA 코드에서 동작하려면 `compile_commands.json`이 필요

### compile_commands.json이란?
- 각 소스 파일이 **어떤 옵션으로 컴파일되는지** 기록한 JSON 파일
- `hm init -b <profile>` 실행 시 빌드 디렉토리에 자동 생성됨
- clangd는 이 파일을 읽어서 include 경로, 매크로 등을 파악

### clangd가 동작하는 과정
1. Neovim에서 `.cpp` 파일을 열면
2. nvim-lspconfig이 clangd 프로세스를 자동 시작
3. clangd가 `compile_commands.json`을 찾아서 프로젝트 구조 파악
4. 이후 자동완성, 에러 표시, 정의 이동 등 가능

> **참고:** HANA 프로젝트 루트에 `compile_commands.json` 심볼릭 링크가 있어야 clangd가 찾을 수 있습니다:
> ```bash
> # 예시: 빌드 디렉토리의 compile_commands.json을 프로젝트 루트에 링크
> ln -sf /path/to/build/compile_commands.json ~/hana/compile_commands.json
> ```

---

## 7. 처음 실행 시 일어나는 일

### 첫 번째 실행
```bash
nvim
```

1. **lazy.nvim 자동 설치:** `init.lua`의 부트스트랩 코드가 lazy.nvim을 GitHub에서 클론
2. **플러그인 자동 설치:** lazy.nvim이 `plugins.lua`에 정의된 모든 플러그인을 다운로드
3. **treesitter 파서 설치:** C, C++, Python 등 언어 파서를 컴파일 & 설치
4. **완료:** 모든 설치가 끝나면 정상적으로 사용 가능

> **인터넷 연결이 필요합니다.** 첫 실행 시 GitHub에서 플러그인을 다운로드합니다.

### 첫 실행 시 화면

처음에 여러 다운로드 메시지가 나타나고, 모두 완료되면 lazy.nvim UI가 표시됩니다.
`q`를 눌러 UI를 닫으면 정상적인 에디터 화면이 나옵니다.

### 두 번째 이후 실행

- 플러그인이 이미 설치되어 있으므로 즉시 시작됩니다
- 추가 다운로드 없이 바로 사용 가능

---

## 8. 문제 해결

### `:checkhealth` 사용법

Neovim에는 자가 진단 도구가 내장되어 있습니다:

```vim
:checkhealth
```

이 명령은 다음을 검사합니다:
- Neovim 버전 및 기본 설정
- 클립보드 지원 여부
- 설치된 LSP 서버 상태
- treesitter 파서 상태
- 플러그인 상태

**특정 항목만 검사:**
```vim
:checkhealth nvim-treesitter
:checkhealth lspconfig
```

### 흔한 문제와 해결

#### 문제: 컬러가 이상하게 보임
- **원인:** 터미널이 트루컬러를 지원하지 않음
- **해결:** 터미널 설정에서 트루컬러 활성화, 또는 `options.lua`에서 `termguicolors = false`로 변경

#### 문제: 플러그인이 설치되지 않음
- **원인:** 인터넷 연결 또는 git 문제
- **해결:** `:Lazy sync` 실행하여 재시도

#### 문제: clangd가 동작하지 않음 (자동완성 안 됨)
- **원인 1:** `compile_commands.json`이 없음
  - `hm init -b <profile>` 실행 후 프로젝트 루트에 심볼릭 링크 생성
- **원인 2:** clangd가 설치되지 않음
  - `clangd --version`으로 확인
- **확인:** `:LspInfo`로 현재 LSP 상태 확인

#### 문제: treesitter 파서 컴파일 에러
- **원인:** C 컴파일러가 없음
- **해결:** `cc --version` 확인. 없으면 시스템 관리자에게 문의

#### 문제: "nvim: command not found"
- **원인:** PATH 설정이 안 됨
- **해결:** `~/.bashrc`에 `export PATH="$HOME/.local/bin:$PATH"` 추가 후 `source ~/.bashrc`

#### 문제: 아이콘이 깨져 보임 (□ 또는 ? 표시)
- **원인:** Nerd Font가 설치되지 않음
- **해결:** 터미널에서 Nerd Font를 설치하고 사용. 또는 아이콘 없이 사용해도 기능에 문제 없음
- **참고:** 로컬 터미널(iTerm2, Windows Terminal 등)에서 폰트를 설정해야 합니다

---

## 참고: 설정 변경 방법

### 옵션 변경
`~/.config/nvim/lua/options.lua` 파일을 수정합니다.
예: 탭 크기를 2로 변경하려면:
```lua
opt.tabstop = 2
opt.shiftwidth = 2
```

### 키맵 변경
`~/.config/nvim/lua/keymaps.lua` 파일을 수정합니다.
예: Leader 키를 스페이스로 변경하려면:
```lua
vim.g.mapleader = " "
```

### 플러그인 추가/제거
`~/.config/nvim/lua/plugins.lua` 파일을 수정합니다.
플러그인을 추가하려면 `require("lazy").setup({...})` 안에 새 항목을 추가하고 Neovim을 재시작합니다.

### 변경 적용
설정 파일을 수정한 후:
1. Neovim을 종료하고 다시 시작, 또는
2. `:source %` 명령으로 현재 파일을 다시 로드 (일부 설정만 가능)
