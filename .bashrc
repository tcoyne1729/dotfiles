#    _               _
#   | |__   __ _ ___| |__  _ __ ___
#   | '_ \ / _` / __| '_ \| '__/ __|
#  _| |_) | (_| \__ \ | | | | | (__
# (_)_.__/ \__,_|___/_| |_|_|  \___|
#
# -----------------------------------------------------
# ML4W bashrc loader
# -----------------------------------------------------

# DON'T CHANGE THIS FILE

# You can define your custom configuration by adding
# files in ~/.config/bashrc
# or by creating a folder ~/.config/bashrc/custom
# with copies of files from ~/.config/bashrc
# You can also create a .bashrc_custom file in your home directory
# -----------------------------------------------------

# -----------------------------------------------------
# Load modular configarion
# -----------------------------------------------------

for f in ~/.config/bashrc/*; do
	if [ ! -d $f ]; then
		c=$(echo $f | sed -e "s=.config/bashrc=.config/bashrc/custom=")
		[[ -f $c ]] && source $c || source $f
	fi
done

# -----------------------------------------------------
# Load single customization file (if exists)
# -----------------------------------------------------

if [ -f ~/.bashrc_custom ]; then
	source ~/.bashrc_custom
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/tom/google-cloud-sdk/path.bash.inc' ]; then . '/home/tom/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/tom/google-cloud-sdk/completion.bash.inc' ]; then . '/home/tom/google-cloud-sdk/completion.bash.inc'; fi

# go path
export PATH=$PATH:/usr/local/go/bin
