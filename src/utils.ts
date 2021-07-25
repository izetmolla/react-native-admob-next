export const createErrorFromErrorData = (errorData: any) => {
    const { message, ...extraErrorInfo } = errorData || {};
    const error: any = new Error(message);
    error.framesToPop = 1;
    return Object.assign(error, extraErrorInfo);
};
