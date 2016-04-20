# HaRe.vim

Vim bindings to the [HaRe Haskell refactoring tool][hare-upstream]

[hare-upstream]: https://github.com/alanz/HaRe

## Usage

This plugin is solidly WIP / holiday project status at the moment, and so there
could be bugs lurking around any corner.

All commands listed below will provide a preview window with a diff of all files
affected by the pending refactor. Pressing <kbd>Enter</kbd> in this window will
apply the refactor to all affected files, but not save them. Pressing
<kbd>q</kbd> will abort.

### Commands:

- `:Hrename newSymbolName` - Rename symbol under the cursor to newSymbolName
- `:Hlifttotop` - Lift local function definition under the cursor to the
  top level
- `:Hiftocase` - if an *entire* `if`/`then`/`else` expression is highlighted in
  visual mode, converts that expression to a `case` statement

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
like GHC versions before 7.10.2. Make sure you're running 7.10.2 or greater at 
a system level and also at a per-project level.

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
