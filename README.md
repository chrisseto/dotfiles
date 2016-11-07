dotfiles
========

##Installing
```bash
$ YOUR_INSTALL_COMMAND $(< packages.txt)
$ ./setup.sh
```

### Correct C-h in neovim
https://github.com/neovim/neovim/issues/2048#issuecomment-78045837
```bash
infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > $TERM.ti
tic $TERM.ti
```
