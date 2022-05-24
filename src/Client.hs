module Client
    ( start
    ) where

import           Common
import qualified Data.Text                     as Text
import qualified Network.HTTP.Client           as Client
import qualified Network.HTTP.Client.TLS       as Client
import qualified Network.HTTP.Types            as HTTP
import qualified Network.Wai                   as HTTP
import qualified Network.Wai.Handler.Warp      as HTTP
import qualified Text.Pretty.Simple            as Simple
import           Universum
import qualified Universum.Unsafe              as Unsafe

runMicroServiceOn :: HTTP.Request -> String -> IO HTTP.Response
runMicroServiceOn httpRequest basePath = Client.getGlobalManager >>= \manager ->
    Client.parseRequest basePath >>= convertRequest httpRequest >>= \clientRequest ->
        Client.httpLbs clientRequest manager >>= \clientResponse -> pure
            let body    = Client.responseBody clientResponse
                status  = Client.responseStatus clientResponse
                headers = Client.responseHeaders clientResponse
            in  HTTP.responseLBS status headers body

app :: HTTP.Application
app request respond = respond =<< case HTTP.pathInfo request of
    "api1" : _ -> request `runMicroServiceOn` "http://localhost:3000/"
    "api2" : _ -> request `runMicroServiceOn` "http://localhost:8000/"
    _          -> pure (HTTP.responseLBS HTTP.status404 [] "Micro service not found")

start :: IO ()
start = Client.newManager Client.defaultManagerSettings >>= Client.setGlobalManager >> HTTP.run 5000 app

