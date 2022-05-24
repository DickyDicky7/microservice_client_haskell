module Common
    ( convertRequest
    ) where

import qualified Network.HTTP.Client           as Client
import qualified Network.Wai                   as HTTP
import           Universum
import qualified Universum.Unsafe              as Unsafe

convertRequest :: HTTP.Request -> Client.Request -> IO Client.Request
convertRequest httpRequest clientRequest = do
    requestBody <- HTTP.getRequestBodyChunk httpRequest
    pure clientRequest { Client.secure         = HTTP.isSecure httpRequest
                       , Client.path           = HTTP.rawPathInfo httpRequest
                       , Client.requestVersion = HTTP.httpVersion httpRequest
                       , Client.method         = HTTP.requestMethod httpRequest
                       , Client.queryString    = HTTP.rawQueryString httpRequest
                       , Client.requestHeaders = HTTP.requestHeaders httpRequest
                       , Client.requestBody    = Client.RequestBodyBS requestBody
                       }
