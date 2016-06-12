capture = (self) ->
   t = self.prototype
   if !!Error.captureStackTrace
     then Error.captureStackTrace self, t
     else @stack = new Error!.stack

export class UnAuthorizedException extends Error
 (@message) -> capture(@)


export class UnAuthenticatedException extends Error
 (@message) -> capture(@)