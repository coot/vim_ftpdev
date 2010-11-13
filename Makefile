PLUGIN 	= VIMVIM
VERSION = 1

SOURCE = ftplugin/vim_vim.vim
SOURCE += doc/vimvim.txt

${Plugin}_${VERSION}.vba: ${SOURCE}
		tar -czf ${PLUGIN}${VERSION}.tar.gz ${SOURCE}
		vim -nX --cmd 'let g:plugin_name = "${PLUGIN}${VERSION}"' -S build.vim -cq!

install:
		rsync -Rv ${SOURCE} ${HOME}/.vim/

clean:		
		rm ${PLUGIN}${VERSION}.vba ${PLUGIN}${VERSION}.tar.gz

test:
		tar -tzf ${PLUGIN}${VERSION}.tar.gz
