
BUILD = ${SOC_WORK}/texdocs

include ${SOC_HOME}/extern/texmf/make/image.mk


${BUILD}/scarvsoc.pdf : scarvsoc.tex  $(wildcard ./tex/*) ${IMAGE_TARGETS} dir
	@TEXINPUTS="${TEXINPUTS}:.:${BUILD}" pdflatex  -output-directory $(dir ${@}) $(basename ${<})
	@TEXINPUTS="${TEXINPUTS}:.:${BUILD}" biber    --output_directory $(dir ${@}) $(basename ${<})
	@TEXINPUTS="${TEXINPUTS}:.:${BUILD}" pdflatex  -output-directory $(dir ${@}) $(basename ${<})
	@TEXINPUTS="${TEXINPUTS}:.:${BUILD}" biber    --output_directory $(dir ${@}) $(basename ${<})
	@TEXINPUTS="${TEXINPUTS}:.:${BUILD}" pdflatex  -output-directory $(dir ${@}) $(basename ${<})

dir   :
	@mkdir --parents ${BUILD}
	@mkdir --parents ${BUILD}/image

all   : dir ${BUILD}/scarvsoc.pdf

clean :
	@rm -rf ${BUILD}

