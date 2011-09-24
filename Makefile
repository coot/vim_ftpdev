PLUGIN 	= FTPDEV
VERSION = _5.5

SOURCE = ftplugin/vim_ftpdev.vim
SOURCE += doc/ftpdev.txt

${Plugin}_${VERSION}.vba: ${SOURCE}
		tar -czf ${PLUGIN}${VERSION}.tar.gz ${SOURCE}
		vim -nX --cmd 'let g:plugin_name = "${PLUGIN}${VERSION}"' -S build.vim -cq!
install:
		rsync -Rv ${SOURCE} ${HOME}/.vim/addons/FTPDEV/
		vim --cmd :helptags\ ${HOME}/.vim/addons/FTPDEV/doc --cmd q!

clean:		
		rm ${PLUGIN}${VERSION}.vba ${PLUGIN}${VERSION}.tar.gz

test:
		tar -tzf ${PLUGIN}${VERSION}.tar.gz
