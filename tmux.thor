#!/usr/bin/env ruby
require 'rubygems'
require 'thor

# this script will setup tmux with some plugins that are useful for Rails development
class Tmux < Thor
  desc "up", "Setup environment"
  def up
    sys_call("brew install tmux", "Installing tmux")
    sys_call("brew install reattach-to-user-namespace", "Installing reattach-to-user-namespace")
    sys_call("git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle", "Cloning vundle")

    copy_file(".tmux.conf", "~/.tmux.conf")
    copy_file(".vimrc", "~/.vimrc")
    copy_file(".vimrc.bundles", "~/.vimrc.bundles")
    copy_file(".zshrc", "~/.zshrc")
    copy_folder("./bundles", "~/.vim")
    sys_call("vim +BundleInstall", "Setting up bundles")
  end

  desc "down", "Remove setup"
  def down
    restore_backup("~/.vimrc")
    restore_backup("~/.tmux.conf")
    restore_backup("~/.vimrc.bundles")
    restore_backup("~/.zshrc")
  end

  private

    def sys_call(method, message=nil)
      puts message
      system(method)
    end

    def restore_backup(file_name)
      destination = expand_path(file_name)
      file_name = expand_path("#{file_name}_old")
      if File.exists?(file_name)
        sys_call("rm #{destination}", "Removing existing version at #{destination}")
        sys_call("mv #{file_name} #{destination}", "Restoring backup")
      else
        sys_call("rm #{destination}", "Removing existing version at #{destination}")
      end
    end

    def copy_file(file_name, destination, overwrite=false)
      file_name = expand_path(file_name)
      destination = expand_path(destination)

      return true unless File.exists?(file_name)

      if File.exists?(destination)
        backup_file(destination)
      end

      sys_call("cp #{file_name} #{destination}", "Copying file #{file_name} to #{destination}")
    end

    def copy_folder(folder, destination)
      folder = expand_path(folder)
      destination = expand_path(destination)
      sys_call("cp -R #{folder} #{destination}", "Copying directory from #{folder} to #{destination}")
    end

    def backup_file(file)
      sys_call("mv #{file} #{file}_old", "Backing up #{file}")
    end

    def expand_path(path)
      File.expand_path(path)
    end
end

Tmux.start
