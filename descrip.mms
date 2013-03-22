! Need to worry about the handling of linker options files
! and generating $(ETCDIR)VERSION.OPT, as well as
!
! Look at MX and MMK as a guide...
!
! What about kit building?  Should we grab the PCSI/VMSINSTAL stuff from
! MMK.  Maybe only PCSI...we're not targetting ancient systems...
!

.IF "$(MMSARCH_NAME)" .EQ "Alpha"
ARCH = AXP
.ELSIF "$(MMSARCH_NAME)" .EQ "IA64"
ARCH = I64
.ELSIF "$(MMSARCH_NAME)" .EQ "VAX"
ARCH = VAX
.ELSE
.ERROR You must define the ARCH macro as one of: VAX, AXP or I64
.ENDIF

MG_FACILITY = SQLITE3
.IFDEF __MADGOAT_BUILD__
BINDIR = MG_BIN:[$(MG_FACILITY)]
ETCDIR = MG_ETC:[$(MG_FACILITY)]
KITDIR = MG_KIT:[$(MG_FACILITY)]
SRCDIR = MG_SRC:[$(MG_FACILITY)]
.ELSE
BINDIR = SYS$DISK:[.BIN-$(ARCH)]
ETCDIR = SYS$DISK:[.ETC-$(ARCH)]
KITDIR = SYS$DISK:[.KIT-$(ARCH)]
SRCDIR = SYS$DISK:[]
.ENDIF

.FIRST
.IFDEF __VAX__
    @ IF (F$SEARCH("SYS$COMMON:[GCC]LOGIN.COM") .NES. "") THEN -
       @SYS$COMMON:[GCC]LOGIN
    @ IF (F$SEARCH("SYS$COMMON:[GCC]LOGIN.COM") .EQS. "") THEN -
       WRITE SYS$OUTPUT "%F, this software will not build without GCC for VAX"
.ENDIF
    @ IF F$PARSE("$(BINDIR)") .EQS. "" THEN CREATE/DIR $(BINDIR)
    @ DEFINE/NOLOG BIN_DIR $(BINDIR)
    @ IF F$PARSE("$(ETCDIR)") .EQS. "" THEN CREATE/DIR $(ETCDIR)
    @ DEFINE/NOLOG ETC_DIR $(ETCDIR)
    @ IF F$PARSE("$(KITDIR)") .EQS. "" THEN CREATE/DIR $(KITDIR)
    @ DEFINE/NOLOG KIT_DIR $(KITDIR)
    @ DEFINE/NOLOG SRC_DIR $(SRCDIR)

MUNG = EDIT/TECO/EXECUTE=

OPT = .$(ARCH)_OPT
CFLAGS = $(CFLAGS)/NAME=AS_IS

.IFDEF __VAX__
CC = GCC
CFLAGS = $(CFLAGS)/OPT=2/SCAN=$(ETCDIR)CONFIG.H
VEC = $(BINDIR)SQLITE3_VECTOR.OBJ
{$(SRCDIR)}.C{$(BINDIR)}.OBJ :
    $(CC)$(CFLAGS) $(MMS$SOURCE)
.ELSE
CFLAGS = $(CFLAGS)/WARN=DISABLE=(LONGEXTERN,EMPTYFILE) -
	 /FIRST_INCLUDE=$(ETCDIR)CONFIG.H/FLOAT=IEEE_FLOAT
VEC = 
{$(SRCDIR)}.C{$(BINDIR)}.OBJ :
    $(CC)$(CFLAGS) $(MMS$SOURCE)+SYS$LIBRARY:SYS$LIB_C/LIB

.ENDIF

OBJECTS = $(BINDIR)ALTER.OBJ,$(BINDIR)ANALYZE.OBJ,$(BINDIR)ATTACH.OBJ,-
	  $(BINDIR)AUTH.OBJ,$(BINDIR)BACKUP.OBJ,$(BINDIR)BITVEC.OBJ,-
	  $(BINDIR)BTMUTEX.OBJ,$(BINDIR)BTREE.OBJ,$(BINDIR)BUILD.OBJ,-
	  $(BINDIR)CALLBACK.OBJ,$(BINDIR)COMPLETE.OBJ,$(BINDIR)CTIME.OBJ,-
	  $(BINDIR)DATE.OBJ,$(BINDIR)DELETE.OBJ,$(BINDIR)EXPR.OBJ,-
	  $(BINDIR)FAULT.OBJ,$(BINDIR)FKEY.OBJ,$(BINDIR)FTS3.OBJ,-
	  $(BINDIR)FTS3_AUX.OBJ,$(BINDIR)FTS3_EXPR.OBJ,-
	  $(BINDIR)FTS3_HASH.OBJ,$(BINDIR)FTS3_PORTER.OBJ,-
	  $(BINDIR)FTS3_SNIPPET.OBJ,$(BINDIR)FTS3_TOKENIZER.OBJ,-
	  $(BINDIR)FTS3_TOKENIZER1.OBJ,$(BINDIR)FTS3_WRITE.OBJ,-
	  $(BINDIR)FUNC.OBJ,$(BINDIR)GLOBAL.OBJ,$(BINDIR)HASH.OBJ,-
	  $(BINDIR)INSERT.OBJ,$(BINDIR)JOURNAL.OBJ,$(BINDIR)LEGACY.OBJ,-
	  $(BINDIR)LOADEXT.OBJ,$(BINDIR)MAIN.OBJ,$(BINDIR)MALLOC.OBJ,-
	  $(BINDIR)MEMJOURNAL.OBJ,$(BINDIR)MEMVMS.OBJ,$(BINDIR)MUTEX.OBJ,-
	  $(BINDIR)MUTEX_NOOP.OBJ,$(BINDIR)MUTEX_VMS.OBJ,-
	  $(BINDIR)NOTIFY.OBJ,$(BINDIR)OPCODES.OBJ,-
	  $(BINDIR)OS.OBJ,$(BINDIR)OS_VMS.OBJ,$(BINDIR)PAGER.OBJ,-
	  $(BINDIR)PARSE.OBJ,$(BINDIR)PCACHE.OBJ,$(BINDIR)PCACHE1.OBJ,-
	  $(BINDIR)PRAGMA.OBJ,$(BINDIR)PREPARE.OBJ,$(BINDIR)PRINTF.OBJ,-
	  $(BINDIR)RANDOM.OBJ,$(BINDIR)RESOLVE.OBJ,$(BINDIR)ROWSET.OBJ,-
	  $(BINDIR)RTREE.OBJ,$(BINDIR)SELECT.OBJ,$(BINDIR)STATUS.OBJ,-
	  $(BINDIR)TABLE.OBJ,$(BINDIR)TOKENIZE.OBJ,$(BINDIR)TRIGGER.OBJ,-
	  $(BINDIR)UPDATE.OBJ,$(BINDIR)UTF.OBJ,$(BINDIR)UTIL.OBJ,-
	  $(BINDIR)VACUUM.OBJ,$(BINDIR)VDBE.OBJ,$(BINDIR)VDBEAPI.OBJ,-
	  $(BINDIR)VDBEAUX.OBJ,$(BINDIR)VDBEBLOB.OBJ,$(BINDIR)VDBEMEM.OBJ,-
	  $(BINDIR)VDBESORT.OBJ,$(BINDIR)VDBETRACE.OBJ,$(BINDIR)VTAB.OBJ,-
	  $(BINDIR)WAL.OBJ,$(BINDIR)WALKER.OBJ,$(BINDIR)WHERE.OBJ

$(BINDIR)SQLITE3_SHR.EXE : $(ETCDIR)CONFIG.H,$(VEC),-
			   $(BINDIR)SQLITE3.OLB($(OBJECTS)),-
			   $(SRCDIR)SQLITE3_SHR$(OPT),$(ETCDIR)VERSION.OPT
    $(LINK)/SHARE=$(MMS$TARGET) $(SRCDIR)SQLITE3_SHR$(OPT)/OPT

$(BINDIR)SQLITE3.EXE : $(ETCDIR)CONFIG.H,-
		       $(BINDIR)SHELL.OBJ,$(BINDIR)SQLITE3_SHR.EXE,-
		       $(SRCDIR)SQLITE3$(OPT),$(ETCDIR)VERSION.OPT
    $(LINK)/EXE=$(MMS$TARGET) $(SRCDIR)SQLITE3$(OPT)/OPT

$(ETCDIR)VERSION.OPT : $(SRCDIR)SQLITE3.H
    @MAKE_VERSION $(MMS$SOURCE) $(MMS$TARGET)

$(ETCDIR)CONFIG.H : $(SRCDIR)DESCRIP.MMS
    @ CLOSE/NOLOG S3P
    @ OPEN/WRITE S3P ETC_DIR:CONFIG.H
    @ WRITE S3P "#define SQLITE_OMIT_WAL 1"
    @ WRITE S3P "#define SQLITE_DEFAULT_PAGE_SIZE 512"
    @ WRITE S3P "#define SQLITE_DEFAULT_SECTOR_SIZE 512"
    @ WRITE S3P "#define SQLITE_ENABLE_ATOMIC_WRITE 1"
    @ WRITE S3P "#define SQLITE_THREADSAFE 1"
    @ WRITE S3P "#undef SQLITE_MUTEX_NOOP"
    @ WRITE S3P "#define SQLITE_FILE_FORMAT 4"
    @ WRITE S3P "#define SQLITE_ENABLE_LOCKING_STYLE 0"
    @ WRITE S3P "#define SQLITE_DISABLE_LFS 1"
    @ WRITE S3P "#define SQLITE_CORE 1"
    @ WRITE S3P "#define SQLITE_OMIT_UTF16 1"
    @ WRITE S3P "#define SQLITE_SOUNDEX 1"
    @ WRITE S3P "#define SQLITE_ENABLE_STAT2 1"
    @ WRITE S3P "#define SQLITE_ENABLE_RTREE 1"
    @ WRITE S3P "#define SQLITE_ENABLE_COLUMN_METADATA 1"
    @ WRITE S3P "#define SQLITE_DEFAULT_FOREIGN_KEYS 1"
    @ WRITE S3P "#define SQLITE_ENABLE_FTS3 1"
    @ WRITE S3P "#define SQLITE_ENABLE_FTS3_PARENTHESIS 1"
    @ WRITE S3P "#ifndef SQLITE_API"
    @ WRITE S3P "# define SQLITE_API"
    @ WRITE S3P "#endif"
    @ CLOSE/NOLOG S3P
    @ TYPE $(MMS$TARGET)

$(BINDIR)SQLITE3_VECTOR.OBJ : $(SRCDIR)SQLITE3_VECTOR.MAR
$(SRCDIR)SQLITE3_VECTOR.MAR : $(BINDIR)SQLITE3.OLB($(OBJECTS))
    $(LIBR)/LIST=$(ETCDIR)SQLITE3.LIS/NAMES $(BINDIR)SQLITE3.OLB/OBJECT
    $(MUNG) MAKE_SYMBOL_VECTOR.TEC -
	$(SRCDIR)SYMBOL_VECTOR.TXT=$(ETCDIR)SQLITE3.LIS $(MMS$TARGET)

CLEAN :
    - DELETE/NOLOG $(BINDIR)*.*;*
    - DELETE/NOLOG $(ETCDIR)*.*;*
    - DELETE/NOLOG $(KITDIR)*.*;*
