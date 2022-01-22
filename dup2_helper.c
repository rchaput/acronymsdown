/*
 * This file defines helper functions to redirect stderr in R.
 *
 * It seems that the default `sink` function available in R does not
 * really redirect the stream. It works well with R messages, but any
 * kind of low-level write (such as a call to `system()`) still outputs
 * directly to the "original" stderr.
 *
 * In C, the `dup2` function can be used to redirect stderr. However,
 * it requires some boilerplate code, which would be hard to use directly
 * in R (opening a new file descriptor, closing the previous, ...).
 *
 * Thus, this file defines 2 functions to wrap the calls to `dup2`:
 * - `begin_dup2`: redirects stderr to the specified file, and returns a copy
 *   of the previous stderr. This copy is useful to revert the redirection
 *   afterwards.
 * - `end_dup2`: redirects stderr to the copy of its original file descriptor,
 *   thus effectively reverting the redirection. After calling this method,
 *   writing to stderr will work as originally.
 *
 * This file must be compiled as a shared library to be used in R scripts:
 * use `R CMD shlib dup2_helper.c` on the command line.
 */

#include <fcntl.h>      // For `open`
#include <unistd.h>     // For `dup`, `dup2`
#include <sys/errno.h>  // For `errno`
#include <R.h>

/*
 * This function duplicates the stderr (makes a copy), replaces it with
 * a new file descriptor pointing to the given pathname, and returns the
 * duplicated STDERR (so it can be later undone).
 *
 * pathname: Path to the file that should be used as the new stderr.
 *  In R, "character" may be a string or vector of strings, thus `pathname`
 *  must be a `char**`. However, we assume that a single string is given.
 *
 * stderr_result: (Result only) Copy of the stder file descriptor, before
 *  it is replaced by the new one. This is returned to the R calling code,
 *  so that the replacement can be undone by calling `end_dup2(stderr_result)`.
 */
void begin_dup2(const char** pathname, int* stderr_result) {

    if (!pathname || !pathname[0]) {
        error("Incorrect arguments in begin_dup2: pathname!");
    }
    if (!stderr_result) {
        error("Incorrect arguments in begin_dup2: stderr_result must not be null!");
    }

    // 1. Make a copy of STDERR (so we can undo the replacement)
    *stderr_result = dup(STDERR_FILENO);
    if (*stderr_result < 0) {
        error("Error while calling dup in begin_dup2: errno=%d", errno);
    }

    // 2. Open the (new) file as a file descriptor
    int flags = O_WRONLY | O_CREAT; // Write only, Create if missing.
    int mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH; // rw-r-r
    int fd = open(pathname[0], flags, mode);
    if (fd < 0) {
        error("Error while calling open in begin_dup2: errno=%d", errno);
    }

    // 3. Replace the previous STDERR by the new fd
    int res = dup2(fd, STDERR_FILENO);
    if (res < 0) {
        error("Error while calling dup2 in begin_dup2: errno=%d", errno);
    }
    close(fd);
}


/*
 * This function reverts the redirection of stderr by replacing it with a
 * copy of its original file descriptor.
 *
 * stderr: File descriptor of the original stderr stream, duplicated before
 *  redirected, i.e., the value that is set by `begin_dup2` for the
 *  (result-only) `stderr_result` param.
 */
void end_dup2(const int* stderr) {
    int res = dup2(*stderr, STDERR_FILENO);
    if (res < 0) {
        error("Error while calling dup2 in end_dup2: errno=%d", errno);
    }
    close(*stderr);
}
