# myDevEnv

맥, Ubuntu, SUSE 계열에서 비슷한 개발 환경을 빠르게 재현하기 위한 dotfiles 저장소입니다. 핵심 목표는 다음 네 가지입니다.

- 기본 로그인 쉘을 `zsh` 기준으로 맞추기
- `tmux` 작업 방식과 키맵을 공통화하기
- `nvim` 을 주력 편집기로 사용하기
- 가능하면 `vi`, `vim`, `editor` 호출도 `nvim` 으로 수렴시키기

---

## 1. 빠른 시작

무엇이 바뀌는지 먼저 확인:

```bash
./setup.sh --dry-run
```

일반적인 적용:

```bash
./setup.sh --set-default-shell
```

Linux에서 시스템 `vi`, `vim`, `editor` 대체까지 `nvim` 으로 맞추기:

```bash
./setup.sh --set-default-shell --set-system-alternatives
```

패키지 설치를 직접 처리하고 링크/설정만 적용:

```bash
./setup.sh --skip-packages
```

---

## 2. setup.sh 가 하는 일

`setup.sh` 는 기존 파일을 덮어쓰지 않고 `*.backup.YYYYMMDD-HHMMSS` 형식으로 백업한 뒤 다음 작업을 수행합니다.

### 2-1. 링크 생성

- `~/.zshrc` -> `_.zshrc`
- `~/.tmux.conf` -> `_.tmux.conf`
- `~/.vimrc` -> `_.vimrc`
- `~/.config/nvim` -> `nvim/`
- `~/bin/tmux-keep-zoom`, `~/bin/tmux-resize-screen`, `~/bin/mycscope`

### 2-2. 실행 파일 우선순위 정리

- `~/bin/vi`, `~/bin/vim`, `~/bin/editor` 를 `nvim` 으로 연결
- macOS에서는 시스템 `/usr/bin/vi` 를 직접 바꾸지 않고 `~/bin` 과 shell alias 로 우선 사용
- Linux에서는 `--set-system-alternatives` 사용 시 `update-alternatives` 로 시스템 기본값도 변경 시도

### 2-3. 패키지 설치

지원 패키지 매니저:

- macOS: `brew`
- Ubuntu/Debian: `apt-get`
- openSUSE/SUSE: `zypper`

기본적으로 다음 패키지를 설치하려고 시도합니다.

- `git`
- `zsh`
- `tmux`
- `neovim`
- `ripgrep`
- `fzf`

가능하면 추가로 설치:

- `cscope`
- `universal-ctags`

### 2-4. 플러그인/부가 구성

- zsh 플러그인:
  - `zsh-autosuggestions`
  - `zsh-syntax-highlighting`
- tmux 플러그인:
  - `tmux-plugins/tpm`
  - `tmux-plugins/tmux-resurrect`
  - `tmux-plugins/tmux-open`
- Neovim 플러그인:
  - `nvim --headless "+Lazy! sync" +qa` 실행

---

## 3. 저장소 구조

```text
my-dev-env/
├── _.zshrc
├── _.tmux.conf
├── _.vimrc
├── setup.sh
├── tmux-keep-zoom
├── tmux-resize-screen
├── mycscope / mycscope.sh
├── nvim/
│   ├── init.lua
│   ├── lua/
│   ├── lazy-lock.json
│   ├── SETUP_GUIDE.md
│   └── NEOVIM_MANUAL.md
└── forcherry*/
```

의미:

- `_.zshrc`: 공통 interactive shell baseline
- `_.tmux.conf`: tmux 키맵, 플러그인 선언, pane 동작
- `_.vimrc`: 레거시 Vim 환경
- `nvim/`: 주력 Neovim 설정
- `setup.sh`: 크로스플랫폼 부트스트랩 진입점

---

## 4. zsh 설정

`_.zshrc` 는 새 환경에서 바로 쓸 수 있는 최소 공통 셸을 목표로 합니다.

### 4-1. PATH 우선순위

앞쪽에 두는 경로:

- `~/bin`
- `~/.local/bin`
- `/opt/homebrew/bin`
- `/usr/local/bin`

이 순서 덕분에 사용자별 wrapper 와 수동 설치 바이너리가 시스템 기본 바이너리보다 우선합니다.

### 4-2. 기본 환경 변수

- `EDITOR=nvim`
- `VISUAL=nvim`
- `PAGER=less`

### 4-3. 기본 동작

- `bindkey -v` 로 vi-style keybinding 사용
- history 공유/중복 축소
- `compinit` 활성화
- `fzf` shell integration 자동 로드 시도

### 4-4. alias

주요 alias:

- `vi`, `vim`, `v` -> `nvim`
- `vimdiff` -> `nvim -d`
- `tm` -> `tmux new-session -A -s main`
- `ll`, `la`
- `gs`, `gc`, `gl`

### 4-5. 로컬 오버라이드

호스트별 예외가 필요하면 다음 파일에 추가:

```bash
~/.zshrc.local
```

이 파일은 저장소에 포함하지 않고 마지막에 로드합니다.

---

## 5. tmux 설정

`_.tmux.conf` 는 vim-like pane workflow 를 기준으로 정리되어 있습니다.

### 5-1. 기본 키

- prefix: `Ctrl-a`
- window split:
  - `prefix + s` -> 아래로 split
  - `prefix + v` -> 옆으로 split
- pane 이동:
  - `prefix + h/j/k/l`
- pane resize:
  - `prefix + <`, `>`, `-`, `+`
- zoom:
  - `prefix + z`
- 마지막 window:
  - `prefix + m`

### 5-2. helper 스크립트

- `tmux-keep-zoom`
- `tmux-resize-screen`

이 스크립트들은 `~/bin` 에 링크된 경로를 사용합니다. macOS 기본 Bash 3.2 에서도 동작하도록 `sh` 호환으로 작성했습니다.

### 5-3. tmux 플러그인

- `tpm`
- `tmux-resurrect`
- `tmux-open`

TPM이 아직 설치되지 않은 환경에서도 `.tmux.conf` 가 바로 깨지지 않도록 안전하게 로드합니다.

---

## 6. Neovim 설정

이 저장소의 편집기 중심은 `vim` 이 아니라 `nvim` 입니다.

### 6-1. 버전 기준

- 권장: `Neovim 0.10+`
- 너무 오래된 배포판 패키지라면 수동 설치 또는 별도 업그레이드 필요

### 6-2. 적용 방식

- `~/.config/nvim` 을 저장소의 `nvim/` 으로 링크
- 첫 실행 또는 `setup.sh` 실행 시 `lazy.nvim` 기반 플러그인 동기화

### 6-3. 주요 구성

- `options.lua`: 기본 편집 옵션
- `keymaps.lua`: 키맵
- `plugins.lua`: 플러그인 선언
- `lsp.lua`: `clangd` 중심 LSP/자동완성 설정

### 6-4. 추가 문서

Neovim 자체 설명은 README에 다 넣지 않고 별도 문서로 분리했습니다.

- [nvim/SETUP_GUIDE.md](nvim/SETUP_GUIDE.md)
- [nvim/NEOVIM_MANUAL.md](nvim/NEOVIM_MANUAL.md)

---

## 7. 플랫폼별 동작 차이

### 7-1. macOS

- `brew` 가 있으면 그대로 사용
- 시스템 `vi` 교체 대신 `~/bin/vi`, `~/bin/vim` 과 alias 로 우선 적용
- login shell 변경은 `--set-default-shell` 로 `chsh` 수행

### 7-2. Ubuntu/Debian

- `apt-get` 로 패키지 설치 시도
- `--set-system-alternatives` 사용 시 `update-alternatives` 로 `vi/vim/editor` 교체 시도

### 7-3. openSUSE/SUSE

- `zypper` 로 패키지 설치 시도
- 배포판에 따라 `neovim` 버전이 낮을 수 있으므로 버전 확인 필요

---

## 8. 수동 운영 명령

Neovim 플러그인만 다시 동기화:

```bash
nvim --headless "+Lazy! sync" +qa
```

tmux 플러그인만 다시 설치:

```bash
~/.tmux/plugins/tpm/bin/install_plugins
```

현재 shell 반영:

```bash
exec zsh
```

---

## 9. 롤백 방법

`setup.sh` 는 변경 전 파일을 백업합니다. 되돌릴 때는 링크를 지우고 백업을 원래 이름으로 복원하면 됩니다.

예시:

```bash
rm ~/.zshrc
mv ~/.zshrc.backup.20260427-000000 ~/.zshrc
```

Linux에서 `update-alternatives` 까지 바꿨다면 필요 시 수동으로 다시 선택합니다.

```bash
sudo update-alternatives --config vi
sudo update-alternatives --config vim
sudo update-alternatives --config editor
```

---

## 10. 트러블슈팅

### 10-1. `nvim` 버전이 너무 낮음

증상:

- Lua plugin 로딩 실패
- LSP / treesitter / lazy.nvim 동작 불안정

조치:

- `nvim --version` 확인
- 0.10 이상으로 수동 설치 후 `./setup.sh --skip-packages` 재실행

### 10-2. 플러그인 다운로드 실패

증상:

- `git clone` 실패
- `Lazy sync` 실패
- TPM plugin install 실패

조치:

- 네트워크 접근 확인
- 회사 서버라면 proxy / firewall 확인
- 패키지만 먼저 맞춘 뒤 `--skip-plugins` 로 적용하고 나중에 수동 동기화

### 10-3. `vi` 가 여전히 system vim 임

원인:

- 새 셸이 아직 안 열림
- `~/bin` 이 PATH 앞쪽이 아님
- Linux에서 system alternative 미설정

조치:

```bash
exec zsh
echo $PATH
command -v vi
command -v vim
```

Linux에서는 필요 시:

```bash
./setup.sh --set-system-alternatives
```

### 10-4. tmux 플러그인이 안 보임

조치:

```bash
~/.tmux/plugins/tpm/bin/install_plugins
tmux source-file ~/.tmux.conf
```

### 10-5. 호스트별 예외 설정이 필요함

공통 저장소 파일을 직접 수정하지 말고 다음 파일을 사용:

```bash
~/.zshrc.local
```

tmux 와 nvim 쪽도 가능하면 저장소 공통 설정은 유지하고, 예외는 사용자 로컬 파일이나 환경 변수로 분리하는 쪽을 권장합니다.
