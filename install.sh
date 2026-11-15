#!/bin/bash
# install.sh - Set up dotfiles on any machine

set -e

DOTFILES_DIR="$HOME/.dotfile"

echo "🔧 Setting up dotfiles..."

# Clone dotfiles repo if it doesn't exist
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📦 Cloning dotfiles repository..."
    git clone https://github.com/Leon-Lam919/personal-dotfile.git "$DOTFILES_DIR"
else
    echo "📦 Dotfiles already cloned, pulling latest..."
    cd "$DOTFILES_DIR" && git pull
fi

cd "$DOTFILES_DIR"

# Backup existing dotfiles
backup_dir="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

echo "💾 Backing up existing dotfiles to $backup_dir"

# List of files to symlink
files=(".vimrc" ".zshrc" ".bashrc" ".gitconfig")

for file in "${files[@]}"; do
    if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
        echo "  Backing up $file"
        mv "$HOME/$file" "$backup_dir/"
    fi
done

# Backup tmux config (stored in the repo as .tmux_conf)
if [ -f "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
    echo "  Backing up .tmux.conf"
    mv "$HOME/.tmux.conf" "$backup_dir/"
fi

# Backup nvim config
if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    echo "  Backing up nvim config"
    mv "$HOME/.config/nvim" "$backup_dir/"
fi

# Create symlinks
echo "🔗 Creating symlinks..."

for file in "${files[@]}"; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
        ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
        echo "  ✓ Linked $file"
    fi
done

# Link tmux config
if [ -f "$DOTFILES_DIR/.tmux_conf" ]; then
    ln -sf "$DOTFILES_DIR/.tmux_conf" "$HOME/.tmux.conf"
    echo "  ✓ Linked .tmux.conf"
fi

# Link nvim config
if [ -d "$DOTFILES_DIR/nvim" ]; then
    mkdir -p "$HOME/.config"
    ln -sfn "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    echo "  ✓ Linked nvim config"
fi

echo "✅ Dotfiles installed!"
echo ""
echo "📝 To sync changes:"
echo "  cd ~/.dotfile"
echo "  git add ."
echo "  git commit -m 'Update dotfiles'"
echo "  git push"
echo ""
echo "📥 To pull changes on other machine:"
echo "  cd ~/.dotfile && git pull"
