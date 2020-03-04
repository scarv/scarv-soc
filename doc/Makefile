
BUILD = ${SOC_WORK}/texdocs

include ${SOC_HOME}/extern/texmf/make/image.mk

GRAPH_SRC = $(wildcard ./graphs/*)
GRAPH_OUT = $(addprefix $(BUILD)/,$(notdir $(GRAPH_SRC:%.dot=%.png)))

$(BUILD)/%.png : ./graphs/%.dot
	dot -Tpng $< > $@

${BUILD}/scarvsoc.pdf : scarvsoc.tex  $(wildcard ./tex/*) ${IMAGE_TARGETS} dir $(GRAPH_OUT)
	@TEXINPUTS="${TEXINPUTS}:.:${BUILD}" pdflatex  -output-directory $(dir ${@}) $(basename ${<})
	@TEXINPUTS="${TEXINPUTS}:.:${BUILD}" biber    --output_directory $(dir ${@}) $(basename ${<})
	@TEXINPUTS="${TEXINPUTS}:.:${BUILD}" pdflatex  -output-directory $(dir ${@}) $(basename ${<})
	@TEXINPUTS="${TEXINPUTS}:.:${BUILD}" biber    --output_directory $(dir ${@}) $(basename ${<})
	@TEXINPUTS="${TEXINPUTS}:.:${BUILD}" pdflatex  -output-directory $(dir ${@}) $(basename ${<})

dir   :
	@mkdir --parents ${BUILD}
	@mkdir --parents ${BUILD}/image

doxygen:
	@mkdir -p ${SOC_WORK}/doc/verilator-testbench
	doxygen verilator-environment.doxygen

all   : dir ${BUILD}/scarvsoc.pdf doxygen

clean :
	@rm -rf ${BUILD}

