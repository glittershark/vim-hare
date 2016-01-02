# HaRe.vim

Vim bindings to the [HaRe Haskell refactoring tool][hare-upstream]

[hare-upstream]: https://github.com/alanz/HaRe

## Usage

This plugin is solidly WIP / holiday project status at the moment, and so
currently only provides (potentially quite buggy) support for renaming symbols.  
To do that, position your cursor on a symbol you'd like to rename and run:

```vim
:Hrename new-symbol-name
```

HaRe.vim will provide you a preview window with a diff of the pending refactor.
You can press <kbd>Enter</kbd> in this window to confirm and apply the refactor
(but not save the file) or <kbd>q</kbd> to abort.

## Installation

### First, install HaRe itself

```shell
cabal install hare
```

Make sure to do this *outside* any sandboxes for now, as hare.vim assumes
`ghc-hare` exists somewhere on your PATH. If you want to override this, you can
set `g:hare_executable` to something like `cabal exec -- ghc-hare`, though
obviously this won't work on a per-project basis.

Another caveat, [mentioned in the hare docs][ghc-version], is that HaRe doesn't
like GHC versions before 7.10.2. Make sure you're running 7.10.2 at a system
level and also at a per-project level.

[ghc-version]: https://github.com/alanz/HaRe#limitations

### Then install the vim plugin

I like [Vundle][] a lot. To install using Vundle, add the following to the
plugin section of your vimrc or other:

```vim
Plugin 'glittershark/vim-hare'
```

Then run `:PluginInstall` from within vim

To install using [Pathogen][]:

```shell
cd ~/.vim/bundle
git clone git://github.com/glittershark/vim-hare.git
```

[Vundle]: https://github.com/VundleVim/Vundle.vim
[Pathogen]: https://github.com/tpope/vim-pathogen
