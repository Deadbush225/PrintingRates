// Macro to throw an error with file and line number information
#define THROW_ERROR(msg)                                                       \
    {                                                                          \
        std::ostringstream oss;                                                \
        oss << msg << " (File: " << __FILE__ << ", Line: " << __LINE__ << ")"; \
        throw std::runtime_error(oss.str());                                   \
    }