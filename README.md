# myDevEnv

개인 개발 환경 설정 파일 모음

---

## 구조

```
my-dev-env/
├── _.vimrc              # Vim 설정 (Vundle 기반)
├── _.tmux.conf          # tmux 설정
├── _.gitignore          # gitignore 템플릿
├── tmux-keep-zoom       # tmux 유틸 스크립트
├── tmux-resize-screen   # tmux 유틸 스크립트
├── mycscope / mycscope.sh  # cscope 유틸
├── nvim/                # Neovim 모던 설정 (Lua 기반)
│   ├── init.lua         # 진입점
│   ├── lua/
│   │   ├── options.lua  # 기본 에디터 옵션
│   │   ├── keymaps.lua  # 키 매핑
│   │   ├── plugins.lua  # lazy.nvim 플러그인 (20개)
│   │   └── lsp.lua      # LSP(clangd) + 자동완성
│   ├── SETUP_GUIDE.md   # 세팅 가이드 (한국어)
│   └── NEOVIM_MANUAL.md # 사용 매뉴얼 (한국어)
├── forcherryblack/      # QMK 키보드 (GH60 Satan)
└── forcherrybrown/      # QMK 키보드 (Minila)
```

---

## Vim 설정 (레거시)

```bash
# Vundle 설치
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# 설정 파일 복사
cp _.vimrc ~/.vimrc

# Vim 실행 후 플러그인 설치
vim +PluginInstall +qall
```

---

## Neovim 설정 (권장)

Lua 기반 모던 설정. Neovim v0.10+ 필요.

### 빠른 설치 (macOS)

```bash
# 1. Neovim 및 ripgrep 설치 (Homebrew)
brew update && brew install neovim ripgrep

# 2. 설정 파일 복사
mkdir -p ~/.config/nvim/lua
cp nvim/init.lua ~/.config/nvim/
cp nvim/lua/*.lua ~/.config/nvim/lua/
cp nvim/*.md ~/.config/nvim/  # 문서도 복사 (선택)

# 3. Neovim 첫 실행 (플러그인 자동 설치)
nvim
```

### 빠른 설치 (Linux)

```bash
# 1. Neovim 최신 버전 설치 (v0.10.4)
curl -L -o /tmp/nvim.tar.gz \
  "https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz"
tar xzf /tmp/nvim.tar.gz -C /tmp/
cp -r /tmp/nvim-linux-x86_64/* ~/.local/
rm -rf /tmp/nvim-linux-x86_64 /tmp/nvim.tar.gz

# 2. PATH 설정 (~/.bashrc에 추가, 시스템 nvim보다 우선)
export PATH="$HOME/.local/bin:$PATH"

# 3. 설정 파일 복사
mkdir -p ~/.config/nvim/lua
cp nvim/init.lua ~/.config/nvim/
cp nvim/lua/*.lua ~/.config/nvim/lua/
cp nvim/*.md ~/.config/nvim/  # 문서도 복사 (선택)

# 4. ripgrep 설치 (telescope grep 검색용)
curl -sL https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz \
  | tar xz -C /tmp/ && cp /tmp/ripgrep-*/rg ~/.local/bin/

# 5. Neovim 첫 실행 (플러그인 자동 설치)
nvim
```

### 포함된 플러그인 (20개)

| 플러그인 | 역할 | 기존 Vim 대응 |
|----------|------|--------------|
| tokyonight.nvim | 컬러스킴 | jellybeans |
| telescope.nvim | 퍼지 검색 | fzf |
| nvim-tree.lua | 파일 탐색기 | NERDTree |
| lualine.nvim | 상태바 | vim-airline |
| nvim-lspconfig | LSP 설정 | vim-lsp |
| nvim-cmp | 자동완성 | asyncomplete |
| nvim-treesitter | 구문 강조 | (없음) |
| gitsigns.nvim | git 변경 표시 | vim-gitgutter |
| vim-fugitive | git 명령어 | (동일) |
| indent-blankline.nvim | 들여쓰기 가이드 | vim-indent-guides |
| Comment.nvim | 주석 토글 | (없음) |

### 문서

- **[SETUP_GUIDE.md](nvim/SETUP_GUIDE.md)** - 설치부터 설정까지 상세 가이드
- **[NEOVIM_MANUAL.md](nvim/NEOVIM_MANUAL.md)** - 사용 매뉴얼 + 플러그인별 가이드 + 단축키 치트시트

---

## tmux 설정

```bash
cp _.tmux.conf ~/.tmux.conf
```
