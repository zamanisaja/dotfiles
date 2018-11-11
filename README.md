# dotfiles

# Install Antigen:
mkdir -pv ~/.zsh/antigen
curl -L git.io/antigen > ~/.zsh/antigen/antigen.zsh

git clone https://github.com/robbyrussell/oh-my-zsh ~/.zsh

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
