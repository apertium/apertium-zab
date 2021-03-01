###############################################################################
## Makefile for apertium-zab
###############################################################################

RELEASE=0.1
VERSION=0.1.0

LANG1=zab
SCRIPT1=Simp
SCRIPT2=Dict
LANG1SCRIPT1=$(LANG1)@$(SCRIPT1)
LANG1SCRIPT2=$(LANG1)@$(SCRIPT2)

BASENAME=apertium-$(LANG1)

TARGETS_COMMON =			\
	$(LANG1).automorf.hfst		\
	$(LANG1).automorf.bin		\
	$(LANG1SCRIPT1).autogen.hfst \
	$(LANG1SCRIPT2).autogen.hfst \
	$(LANG1SCRIPT1).autogen.bin \
	$(LANG1SCRIPT2).autogen.bin \
	$(LANG1).autopgen.bin		\
	$(LANG1).rlx.bin				\
	$(LANG1).autoseq.bin			\
	$(LANG1).revautoseq.bin		\
	.deps/$(LANG1SCRIPT1)-$(LANG1SCRIPT2).hfst \
	.deps/$(LANG1SCRIPT2)-$(LANG1SCRIPT1).hfst

SHELL = /bin/bash -o pipefail

# This include defines goals for install-modes, .deps/.d, autobil.prefixes and .mode files:
@ap_include@

###############################################################################
## zab transducer
###############################################################################

.deps/$(LANG1).twol.hfst: $(BASENAME).$(LANG1).twol .deps/.d
	hfst-twolc $< -o $@

# RL transducers are for generation
.deps/$(LANG1SCRIPT1).RL.lexd: $(BASENAME).$(LANG1).lexd .deps/.d
	cat $< | grep -v 'Dir/LR' | grep -v 'Orth/$(SCRIPT2)' > $@

.deps/$(LANG1SCRIPT2).RL.lexd: $(BASENAME).$(LANG1).lexd .deps/.d
	cat $< | grep -v 'Dir/LR' | grep -v 'Orth/$(SCRIPT1)' > $@

# LR transducers are for analysis
.deps/$(LANG1SCRIPT1).LR.lexd: $(BASENAME).$(LANG1).lexd .deps/.d
	cat $< | grep -v 'Dir/RL' | grep -v 'Orth/$(SCRIPT2)' > $@

.deps/$(LANG1SCRIPT2).LR.lexd: $(BASENAME).$(LANG1).lexd .deps/.d
	cat $< | grep -v 'Dir/RL' | grep -v 'Orth/$(SCRIPT1)' > $@

.deps/$(LANG1SCRIPT1).RL.lexd.hfst: .deps/$(LANG1SCRIPT1).RL.lexd
	lexd $< | hfst-txt2fst > $@

.deps/$(LANG1SCRIPT2).RL.lexd.hfst: .deps/$(LANG1SCRIPT2).RL.lexd
	lexd $< | hfst-txt2fst > $@

.deps/$(LANG1SCRIPT1).LR.lexd.hfst: .deps/$(LANG1SCRIPT1).LR.lexd
	lexd $< | hfst-txt2fst > $@

.deps/$(LANG1SCRIPT2).LR.lexd.hfst: .deps/$(LANG1SCRIPT2).LR.lexd
	lexd $< | hfst-txt2fst > $@

.deps/$(LANG1SCRIPT1).RL.hfst: .deps/$(LANG1SCRIPT1).RL.lexd.hfst .deps/$(LANG1).twol.hfst
	hfst-compose-intersect -1 .deps/$(LANG1SCRIPT1).RL.lexd.hfst -2 .deps/$(LANG1).twol.hfst -o $@

.deps/$(LANG1SCRIPT2).RL.hfst: .deps/$(LANG1SCRIPT2).RL.lexd.hfst .deps/$(LANG1).twol.hfst
	hfst-compose-intersect -1 .deps/$(LANG1SCRIPT2).RL.lexd.hfst -2 .deps/$(LANG1).twol.hfst -o $@

.deps/$(LANG1SCRIPT1).LR.hfst: .deps/$(LANG1SCRIPT1).LR.lexd.hfst .deps/$(LANG1).twol.hfst
	hfst-compose-intersect -1 .deps/$(LANG1SCRIPT1).LR.lexd.hfst -2 .deps/$(LANG1).twol.hfst -o $@

.deps/$(LANG1SCRIPT2).LR.hfst: .deps/$(LANG1SCRIPT2).LR.lexd.hfst .deps/$(LANG1).twol.hfst
	hfst-compose-intersect -1 .deps/$(LANG1SCRIPT2).LR.lexd.hfst -2 .deps/$(LANG1).twol.hfst -o $@

# the analyser is a combination of the two orthographies' analysers
.deps/$(LANG1).LR.hfst: .deps/$(LANG1SCRIPT1).LR.hfst .deps/$(LANG1SCRIPT2).LR.hfst
	hfst-union -1 $< -2 .deps/$(LANG1SCRIPT2).LR.hfst > $@

$(LANG1SCRIPT1).autogen.hfst: .deps/$(LANG1SCRIPT1).RL.hfst
	hfst-minimise $< | hfst-fst2fst -O -o $@

$(LANG1SCRIPT2).autogen.hfst: .deps/$(LANG1SCRIPT2).RL.hfst
	hfst-minimise $< | hfst-fst2fst -O -o $@

.deps/$(LANG1).spellrelax.hfst: $(BASENAME).$(LANG1).spellrelax
	hfst-regexp2fst -S -o $@ < $<

$(LANG1).automorf.hfst: .deps/$(LANG1).LR.hfst .deps/$(LANG1).spellrelax.hfst
	hfst-compose-intersect -1 $< -2 .deps/$(LANG1).spellrelax.hfst | hfst-invert | hfst-minimise | hfst-fst2fst -O -o $@

#$(LANG1).automorf.hfst: .deps/$(LANG1).LR.hfst
#	hfst-invert $< | hfst-minimise | hfst-fst2fst -O -o $@

$(LANG1SCRIPT1).autogen.att.gz: $(LANG1SCRIPT1).autogen.hfst
	hfst-fst2txt $< | gzip -9 -c -n > $@

$(LANG1SCRIPT2).autogen.att.gz: $(LANG1SCRIPT2).autogen.hfst
	hfst-fst2txt $< | gzip -9 -c -n > $@

$(LANG1).automorf.att.gz: $(LANG1).automorf.hfst
	hfst-fst2txt $< | gzip -9 -c -n > $@

$(LANG1SCRIPT1).autogen.bin: $(LANG1SCRIPT1).autogen.att.gz .deps/.d
	zcat < $< > .deps/$(LANG1SCRIPT1).autogen.att
	lt-comp lr .deps/$(LANG1SCRIPT1).autogen.att $@

$(LANG1SCRIPT2).autogen.bin: $(LANG1SCRIPT2).autogen.att.gz .deps/.d
	zcat < $< > .deps/$(LANG1SCRIPT2).autogen.att
	lt-comp lr .deps/$(LANG1SCRIPT2).autogen.att $@

$(LANG1).automorf.bin: $(LANG1).automorf.att.gz .deps/.d
	zcat < $< > .deps/$(LANG1).automorf.att
	lt-comp lr .deps/$(LANG1).automorf.att $@

$(LANG1).autopgen.bin: $(BASENAME).post-$(LANG1).dix
	lt-comp lr $< $@

###############################################################################
## Orthography converters
###############################################################################

.deps/$(LANG1SCRIPT1)-$(LANG1SCRIPT2).hfst: .deps/$(LANG1SCRIPT1).RL.hfst .deps/$(LANG1SCRIPT2).RL.hfst
	hfst-invert $< | hfst-compose-intersect -1 - -2 `echo $(word 2,$^)` | hfst-minimise > $@

.deps/$(LANG1SCRIPT2)-$(LANG1SCRIPT1).hfst: .deps/$(LANG1SCRIPT2).RL.hfst .deps/$(LANG1SCRIPT1).RL.hfst
	hfst-invert $< | hfst-compose-intersect -1 - -2 `echo $(word 2,$^)` | hfst-minimise > $@


###############################################################################
## Debugging transducers (for testvoc)
###############################################################################

debug: .deps/$(LANG1).LR-debug.hfst .deps/$(LANG1).lexc.hfst

.deps/$(LANG1).LR-debug.hfst: $(BASENAME).$(LANG1).lexc .deps/.d
	cat $< | grep -v 'Dir/RL' | grep -v 'Use/Circ' > .deps/$(LANG1).LR-debug.lexc
	hfst-lexc .deps/$(LANG1).LR-debug.lexc -o .deps/$(LANG1).LR-debug.lexc.hfst -v
	hfst-compose-intersect -1 .deps/$(LANG1).LR-debug.lexc.hfst -2 .deps/$(LANG1).twol.hfst -o $@

.deps/$(LANG1).lexc.hfst: .deps/$(LANG1).RL.lexc.hfst
	hfst-fst2fst -O -i $< -o $@

###############################################################################
## Disambiguation rules
###############################################################################

$(LANG1).rlx.bin: $(BASENAME).$(LANG1).rlx $(CGCOMP)
	$(CGCOMP) $< $@

###############################################################################
## Multi-word expressions
###############################################################################

$(LANG1).autoseq.bin: $(BASENAME).$(LANG1).lsx
	lsx-comp lr $< $@

$(LANG1).revautoseq.bin: $(BASENAME).$(LANG1).lsx
	lsx-comp rl $< $@

###############################################################################
## Spell checker
###############################################################################

$(LANG1).zhfst: .deps/acceptor.default.hfst .deps/errmodel.default.hfst
	rm -f $@
	zip -j $@ .deps/acceptor.default.hfst .deps/errmodel.default.hfst speller/index.xml

.deps/errmodel.default.hfst: .deps/words.default.hfst .deps/strings.default.hfst
	python dev/editdist.py -v -s -d 1 -e '@0@' -i speller/editdist.default.txt -a .deps/acceptor.default.hfst \
	| hfst-txt2fst  -e '@0@' -o .deps/editdist.default.hfst
	hfst-disjunct .deps/strings.default.hfst .deps/editdist.default.hfst \
	| hfst-minimise | hfst-repeat -f 1 -t 2 -o .deps/editstrings.default.hfst
	hfst-disjunct .deps/words.default.hfst .deps/editstrings.default.hfst \
	| hfst-fst2fst  -f olw -o $@

.deps/words.default.hfst: speller/words.default.txt
	grep -v -e "^#" -e "^$$" $< | hfst-strings2fst  -j -o $@

.deps/strings.default.hfst: speller/strings.default.txt .deps/anystar.hfst
	grep -v -e "^#" -e "^$$" $< | hfst-strings2fst  -j | hfst-concatenate .deps/anystar.hfst - |\
	hfst-concatenate - .deps/anystar.hfst -o $@

.deps/anystar.hfst:
	echo "?*;" | hfst-regexp2fst -S -o $@

.deps/acceptor.default.hfst: $(LANG1).autogen.hfst
	cat $< | hfst-fst2fst -t | hfst-project  --project=lower | hfst-minimise |hfst-fst2fst  -f olw -o $@


###############################################################################
## Unigram tagger
###############################################################################

$(LANG1).prob: corpus/$(LANG1).tagged
	apertium-tagger -s 0 -u 2 $@ $<

###############################################################################
## Distribution
###############################################################################

EXTRA_DIST=$(BASENAME).$(LANG1).lexc		\
		$(BASENAME).$(LANG1).twol	\
		$(BASENAME).$(LANG1).rlx	\
		$(BASENAME).post-$(LANG1).dix	\
		$(LANG1).prob			\
		modes.xml

###############################################################################
## Installation stuff
###############################################################################
#
#   apertium_zab_dir: This is where the compiled binaries go
#   apertium_zab_srcdir: This is where the source files go

apertium_zabdir=$(prefix)/share/apertium/$(BASENAME)/
apertium_zab_srcdir=$(prefix)/share/apertium/$(BASENAME)/

EXTRA_TARGETS=

if HAVE_HFSTOSPELL
EXTRA_TARGETS += $(LANG1).zhfst
endif # HAVE_HFSTOSPELL

apertium_zab_DATA=$(TARGETS_COMMON) $(EXTRA_TARGETS)

pkgconfigdir = $(prefix)/share/pkgconfig
pkgconfig_DATA = $(BASENAME).pc

noinst_DATA=modes/$(LANG1)-morph.mode

install-data-local: install-modes
	test -d $(DESTDIR)$(apertium_zab_srcdir) || mkdir -p $(DESTDIR)$(apertium_zab_srcdir)
	$(INSTALL_DATA) $(BASENAME).$(LANG1).lexc $(DESTDIR)$(apertium_zab_srcdir)
	$(INSTALL_DATA) $(BASENAME).$(LANG1).twol $(DESTDIR)$(apertium_zab_srcdir)
	$(INSTALL_DATA) $(BASENAME).$(LANG1).rlx $(DESTDIR)$(apertium_zab_srcdir)
	$(INSTALL_DATA) $(BASENAME).post-$(LANG1).dix $(DESTDIR)$(apertium_zab_srcdir)

###############################################################################
## Cleanup
###############################################################################

CLEANFILES = $(TARGETS_COMMON)
clean-local:
	-rm -rf .deps modes

###############################################################################
## Test
###############################################################################

test: all
	echo "TODO test sentence" | apertium -d . zab-morph | tee .test-mt
	@echo "TODO test analysis results" > .test-ref
	@diff .test-ref .test-mt
	@rm .test-ref .test-mt
