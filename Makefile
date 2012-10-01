PLUGIN 	= FTPDEV
VERSION = _6.1

SOURCE = ftplugin/vim_ftpdev.vim
SOURCE += doc/ftpdev.txt

${Plugin}_${VERSION}.vmb: ${SOURCE}
		tar -czf ${PLUGIN}${VERSION}.tar.gz ${SOURCE}
		vim -nX --cmd 'let g:plugin_name = "${PLUGIN}${VERSION}"' -S build.vim -cq!
install:
		rsync -Rv ${SOURCE} ${HOME}/.vim/vam-addons/FTPDEV/
		vim --cmd :helptags\ ${HOME}/.vim/vam-addons/FTPDEV/doc --cmd q!

clean:		
		rm ${PLUGIN}${VERSION}.vmb ${PLUGIN}${VERSION}.tar.gz

test:
		tar -tzf ${PLUGIN}${VERSION}.tar.gz
