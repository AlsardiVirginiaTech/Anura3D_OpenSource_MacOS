    !*****************************************************************************
    !
    !   Anura3D - macOS/POSIX compatibility layer for dynamic library loading
    !
    !   On Windows with Intel Fortran, the external soil model (ESM) libraries are
    !   loaded through the Win32 API in the 'kernel32' module (LoadLibrary /
    !   GetProcAddress, with the HANDLE kind).
    !
    !   Those do not exist on macOS or Linux. This module provides drop-in
    !   equivalents with the same names and semantics, implemented on top of the
    !   POSIX dynamic loader (dlopen / dlsym) via ISO_C_BINDING, so that the
    !   calling code in ReadMaterialData, ExternalSoilModel and MPMDynamicImplicit
    !   needs no change.
    !
    !   This module is compiled to an empty shell under Intel Fortran, where the
    !   real kernel32 versions are used instead.
    !
    !   NOTE: on macOS the loaded soil model libraries must be built as .dylib
    !   (not .dll). The library name constants in ReadMaterialData are unchanged.
    !
    !*****************************************************************************

      module ModDynamicLoading

#ifndef __INTEL_COMPILER

      use, intrinsic :: iso_c_binding

      implicit none

      ! Kind matching the Win32 HANDLE used by the Intel kernel32 module:
      ! an integer wide enough to hold a native pointer.
      integer, parameter :: HANDLE = C_INTPTR_T

      ! dlopen() modes (as defined in dlfcn.h on macOS and Linux)
      integer(C_INT), parameter :: RTLD_LAZY = 1
      integer(C_INT), parameter :: RTLD_NOW  = 2

      interface

        function c_dlopen(filename, mode) bind(C, name = "dlopen") result(res)
          import :: C_CHAR, C_INT, C_PTR
          character(kind = C_CHAR), dimension(*), intent(in) :: filename
          integer(C_INT), value :: mode
          type(C_PTR) :: res
        end function c_dlopen

        function c_dlsym(handle, symbol) bind(C, name = "dlsym") result(res)
          import :: C_CHAR, C_PTR, C_FUNPTR
          type(C_PTR), value :: handle
          character(kind = C_CHAR), dimension(*), intent(in) :: symbol
          type(C_FUNPTR) :: res
        end function c_dlsym

        function c_dlclose(handle) bind(C, name = "dlclose") result(res)
          import :: C_PTR, C_INT
          type(C_PTR), value :: handle
          integer(C_INT) :: res
        end function c_dlclose

      end interface

      contains

        function LoadLibrary(FileName) result(LibHandle)
        !*********************************************************************
        !   Opens a shared library and returns an opaque handle, or 0 on
        !   failure. Mirrors the Win32 LoadLibrary used on Windows.
        !*********************************************************************

        implicit none

          character(len = *), intent(in) :: FileName
          integer(HANDLE) :: LibHandle

          ! local variables
          type(C_PTR) :: CHandle

          CHandle = c_dlopen(TerminatedName(FileName), RTLD_LAZY)
          LibHandle = transfer(CHandle, LibHandle)

        end function LoadLibrary


        function GetProcAddress(LibHandle, SymbolName) result(ProcAddress)
        !*********************************************************************
        !   Looks up a symbol in a library previously opened by LoadLibrary
        !   and returns its address, or 0 if the symbol is not found.
        !   Mirrors the Win32 GetProcAddress used on Windows.
        !*********************************************************************

        implicit none

          integer(HANDLE), intent(in) :: LibHandle
          character(len = *), intent(in) :: SymbolName
          integer(HANDLE) :: ProcAddress

          ! local variables
          type(C_PTR) :: CHandle
          type(C_FUNPTR) :: CProc

          CHandle = transfer(LibHandle, CHandle)
          CProc = c_dlsym(CHandle, TerminatedName(SymbolName))
          ProcAddress = transfer(CProc, ProcAddress)

        end function GetProcAddress


        function FreeLibrary(LibHandle) result(Status)
        !*********************************************************************
        !   Closes a library opened by LoadLibrary. Returns 0 on success,
        !   following the dlclose() convention.
        !*********************************************************************

        implicit none

          integer(HANDLE), intent(in) :: LibHandle
          integer(C_INT) :: Status

          ! local variables
          type(C_PTR) :: CHandle

          CHandle = transfer(LibHandle, CHandle)
          Status = c_dlclose(CHandle)

        end function FreeLibrary


        function TerminatedName(Name) result(res)
        !*********************************************************************
        !   Returns Name as a NUL-terminated C string. Call sites may already
        !   append char(0) themselves; a trailing NUL is idempotent for C, as
        !   the string simply ends at the first one.
        !*********************************************************************

        implicit none

          character(len = *), intent(in) :: Name
          character(len = len_trim(Name) + 1, kind = C_CHAR) :: res

          res = trim(Name) // C_NULL_CHAR

        end function TerminatedName

#endif

      end module ModDynamicLoading
