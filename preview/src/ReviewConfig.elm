module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import Install.ClauseInCase as ClauseInCase
import Install.FieldInTypeAlias as FieldInTypeAlias
import Install.Function.InsertFunction as InsertFunction
import Install.Function.ReplaceFunction as ReplaceFunction
import Install.Import as Import exposing(module_, qualified, withExposedValues, withAlias)
import Install.Initializer as Initializer
import Install.InitializerCmd as InitializerCmd
import Install.Subscription as Subscription
import Install.Type
import Install.TypeVariant as TypeVariant
import Regex
import Review.Rule exposing (Rule)


config =
    configAtmospheric



-- ++ configRoute -- ++ configView


--configAuth =
--    configAuthTypes ++ configAuthBackend ++ configAuthFrontend ++ configRoute
--

configAtmospheric : List Rule
configAtmospheric =
    [ -- Add fields randomAtmosphericNumbers and time to BackendModel
      -- 13 rules, stands alone.
      Import.qualified "Types" [ "Http" ] |> Import.makeRule
    , Import.qualified "Backend" [ "Atmospheric", "Dict", "Time", "Task", "MagicLink.Helper" ] |> Import.makeRule

    --
    , FieldInTypeAlias.makeRule "Types" "BackendModel" [
        "randomAtmosphericNumbers : Maybe (List Int)","time : Time.Posix"]
    --
     ,  TypeVariant.makeRule "Types" "BackendMsg" [
          "GotAtmosphericRandomNumbers (Result Http.Error String)"
        , "SetLocalUuidStuff (List Int)"
        , "GotFastTick Time.Posix" ]

--
--    , Initializer.makeRule "Backend" "init" [
--        { field = "randomAtmosphericNumbers", value =  "Just [ 235880, 700828, 253400, 602641 ]" }
--      , { field = "time", value = "Time.millisToPosix 0" } ]
--    , InitializerCmd.makeRule "Backend" "init" [ "Time.now |> Task.perform GotFastTick", "MagicLink.Helper.getAtmosphericRandomNumbers" ]


    --
    , ClauseInCase.init "Backend" "update" "GotAtmosphericRandomNumbers randomNumberString" "Atmospheric.setAtmosphericRandomNumbers model randomNumberString" |> ClauseInCase.makeRule
    , ClauseInCase.init "Backend" "update" "SetLocalUuidStuff randomInts" "(model, Cmd.none)" |> ClauseInCase.makeRule
    , ClauseInCase.init "Backend" "update" "GotFastTick time" "( { model | time = time } , Cmd.none )" |> ClauseInCase.makeRule
    ]


configUsers : List Rule
configUsers =
    -- 13 rules, follows configA
    [ Import.qualified "Types" [ "User" ] |> Import.makeRule
    , Import.config "Types" [ module_ "Dict" |> withExposedValues [ "Dict" ]  ] |> Import.makeRule
    , FieldInTypeAlias.makeRule "Types" "BackendModel"
       [ "users: Dict.Dict User.EmailString User.User"
       , "userNameToEmailString : Dict.Dict User.Username User.EmailString" ]
    , FieldInTypeAlias.makeRule "Types" "LoadedModel" ["users : Dict.Dict User.EmailString User.User"]

    --
    , Import.qualified "Backend" [ "Time", "Task", "LocalUUID" ] |> Import.makeRule
    , Import.config "Backend" [
         module_ "MagicLink.Helper" |> withAlias "Helper"
       , module_ "Dict" |> withExposedValues ["Dict"]] |> Import.makeRule
    --
    , Import.qualified "Frontend" [ "Dict" ] |> Import.makeRule

    --

    --
    , Initializer.makeRule "Frontend" "initLoaded" [{field = "users", value = "Dict.empty"}]
    , Initializer.makeRule "Backend" "init"
       [ {field = "userNameToEmailString", value = "Dict.empty"}, {field = "users", value =  "Dict.empty"}]

    --
    , ReplaceFunction.init "Frontend" "tryLoading" tryLoading1
        |> ReplaceFunction.makeRule
    ]

--
--configAuthTypes : List Rule
--configAuthTypes =
--    -- 22 rules
--    [ Import.initSimple "Types" [ "AssocList", "Auth.Common", "LocalUUID", "MagicLink.Types", "Session" ] |> Import.makeRule
--
--    -- FRONTEND MSG
--    , Install.TypeVariant.makeRule "Types" "FrontendMsg" "SignInUser User.SignInData"
--    , Install.TypeVariant.makeRule "Types" "FrontendMsg" "AuthFrontendMsg MagicLink.Types.Msg"
--    , Install.TypeVariant.makeRule "Types" "FrontendMsg" "SetRoute_ Route"
--    , Install.TypeVariant.makeRule "Types" "FrontendMsg" "LiftMsg MagicLink.Types.Msg"
--
--    -- BACKEND MSG
--    , Install.TypeVariant.makeRule "Types" "BackendMsg" "AuthBackendMsg Auth.Common.BackendMsg"
--    , Install.TypeVariant.makeRule "Types" "BackendMsg" "AutoLogin SessionId User.SignInData"
--    , Install.TypeVariant.makeRule "Types" "BackendMsg" "OnConnected SessionId ClientId"
--
--    -- BackendModel
--    , FieldInTypeAlias.makeRule "Types" "BackendModel" "localUuidData : Maybe LocalUUID.Data"
--    , FieldInTypeAlias.makeRule "Types" "BackendModel" "pendingAuths : Dict Lamdera.SessionId Auth.Common.PendingAuth"
--    , FieldInTypeAlias.makeRule "Types" "BackendModel" "pendingEmailAuths : Dict Lamdera.SessionId Auth.Common.PendingEmailAuth"
--    , FieldInTypeAlias.makeRule "Types" "BackendModel" "sessions : Dict SessionId Auth.Common.UserInfo"
--    , FieldInTypeAlias.makeRule "Types" "BackendModel" "secretCounter : Int"
--    , FieldInTypeAlias.makeRule "Types" "BackendModel" "sessionDict : AssocList.Dict SessionId String"
--    , FieldInTypeAlias.makeRule "Types" "BackendModel" "pendingLogins : MagicLink.Types.PendingLogins"
--    , FieldInTypeAlias.makeRule "Types" "BackendModel" "log : MagicLink.Types.Log"
--    , FieldInTypeAlias.makeRule "Types" "BackendModel" "sessionInfo : Session.SessionInfo"
--
--    --  ToBackend
--    , Install.TypeVariant.makeRule "Types" "ToBackend" "AuthToBackend Auth.Common.ToBackend"
--    , Install.TypeVariant.makeRule "Types" "ToBackend" "AddUser String String String"
--    , Install.TypeVariant.makeRule "Types" "ToBackend" "RequestSignUp String String String"
--    , Install.TypeVariant.makeRule "Types" "ToBackend" "GetUserDictionary"
--
--    --
--    , FieldInTypeAlias.makeRule "Types" "LoadedModel" "magicLinkModel : MagicLink.Types.Model"
--    ]
--
--
--configAuthFrontend : List Rule
--configAuthFrontend =
--    -- 22 rules
--    [ Import.initSimple "Frontend" [ "MagicLink.Types", "Auth.Common" ] |> Import.makeRule
--
--    -- Loaded Model
--    , Initializer.makeRule "Frontend" "initLoaded" "magicLinkModel" "Pages.SignIn.init loadingModel.initUrl"
--    , ClauseInCase.init "Frontend" "updateFromBackendLoaded" "AuthToFrontend authToFrontendMsg" "MagicLink.Auth.updateFromBackend authToFrontendMsg model.magicLinkModel |> Tuple.mapFirst (\\magicLinkModel -> { model | magicLinkModel = magicLinkModel })"
--        |> ClauseInCase.withInsertAtBeginning
--        |> ClauseInCase.makeRule
--    , ClauseInCase.init "Frontend" "updateFromBackendLoaded" "GotUserDictionary users" "( { model | users = users }, Cmd.none )"
--        |> ClauseInCase.withInsertAtBeginning
--        |> ClauseInCase.makeRule
--    , ClauseInCase.init "Frontend" "updateFromBackendLoaded" "UserRegistered user" "MagicLink.Frontend.userRegistered model.magicLinkModel user |> Tuple.mapFirst (\\magicLinkModel -> { model | magicLinkModel = magicLinkModel })"
--        |> ClauseInCase.withInsertAtBeginning
--        |> ClauseInCase.makeRule
--    , ClauseInCase.init "Frontend" "updateFromBackendLoaded" "GotMessage message" "({model | message = message}, Cmd.none)"
--        |> ClauseInCase.withInsertAtBeginning
--        |> ClauseInCase.makeRule
--
--    -- PROBLEM IF THE CODE AT (XX) IS MOVED HERE:
--    -- If both of the two rules are active, we get an infinite loop.
--    -- If just one is, all is fine.
--    , ClauseInCase.init "Frontend" "updateLoaded" "SetRoute_ route" "( { model | route = route }, Cmd.none )" |> ClauseInCase.makeRule
--    , ClauseInCase.init "Frontend" "updateLoaded" "AuthFrontendMsg authToFrontendMsg" "MagicLink.Auth.update authToFrontendMsg model.magicLinkModel |> Tuple.mapFirst (\\magicLinkModel -> { model | magicLinkModel = magicLinkModel })" |> ClauseInCase.makeRule
--    , ClauseInCase.init "Frontend" "updateLoaded" "SignInUser userData" "MagicLink.Frontend.signIn model userData" |> ClauseInCase.makeRule
--
--    -- To Frontend
--    , Install.TypeVariant.makeRule "Types" "ToFrontend" "AuthToFrontend Auth.Common.ToFrontend"
--    , Install.TypeVariant.makeRule "Types" "ToFrontend" "AuthSuccess Auth.Common.UserInfo"
--    , Install.TypeVariant.makeRule "Types" "ToFrontend" "UserInfoMsg (Maybe Auth.Common.UserInfo)"
--    , Install.TypeVariant.makeRule "Types" "ToFrontend" "CheckSignInResponse (Result BackendDataStatus User.SignInData)"
--    , Install.TypeVariant.makeRule "Types" "ToFrontend" "GetLoginTokenRateLimited"
--    , Install.TypeVariant.makeRule "Types" "ToFrontend" "RegistrationError String"
--    , Install.TypeVariant.makeRule "Types" "ToFrontend" "SignInError String"
--    , Install.TypeVariant.makeRule "Types" "ToFrontend" "UserSignedIn (Maybe User.User)"
--    , Install.TypeVariant.makeRule "Types" "ToFrontend" "UserRegistered User.User"
--    , Install.TypeVariant.makeRule "Types" "ToFrontend" "GotUserDictionary (Dict.Dict User.EmailString User.User)"
--    , Install.TypeVariant.makeRule "Types" "ToFrontend" "GotMessage String"
--    , Install.Type.makeRule "Types" "BackendDataStatus" [ "Sunny", "LoadedBackendData", "Spell String Int" ]
--
--    -- (XX):
--    , Import.initSimple "Frontend" [ "MagicLink.Frontend", "MagicLink.Auth", "Dict", "Pages.SignIn", "Pages.Home", "Pages.Admin", "Pages.TermsOfService", "Pages.Notes" ] |> Import.makeRule
--    , ClauseInCase.init "Frontend" "updateLoaded" "LiftMsg _" "( model, Cmd.none )" |> ClauseInCase.makeRule
--
--    --
--    -- Causes infinite loop
--    , Function.ReplaceFunction.init "Frontend" "tryLoading" tryLoading2
--        |> Function.ReplaceFunction.makeRule
--    ]
--
--
--configAuthBackend : List Rule
--configAuthBackend =
--    -- 19 rules
--    [ ClauseInCase.init "Backend" "update" "AuthBackendMsg authMsg" "Auth.Flow.backendUpdate (MagicLink.Auth.backendConfig model) authMsg" |> ClauseInCase.makeRule
--    , ClauseInCase.init "Backend" "update" "AutoLogin sessionId loginData" "( model, Lamdera.sendToFrontend sessionId (AuthToFrontend <| Auth.Common.AuthSignInWithTokenResponse <| Ok <| loginData) )" |> ClauseInCase.makeRule
--    , ClauseInCase.init "Backend" "update" "OnConnected sessionId clientId" "( model, Reconnect.connect model sessionId clientId )" |> ClauseInCase.makeRule
--    , ClauseInCase.init "Backend" "update" "ClientConnected sessionId clientId" "( model, Reconnect.connect model sessionId clientId )" |> ClauseInCase.makeRule
--    , Import.initSimple "Backend"
--        [ "AssocList"
--        , "Auth.Common"
--        , "Auth.Flow"
--        , "MagicLink.Auth"
--        , "MagicLink.Backend"
--        , "Reconnect"
--        , "User"
--        ]
--        |> Import.makeRule
--
--    -- Init
--    , Initializer.makeRule "Backend" "init"
--        [ {field  = "sessions", value = "Dict.empty"} , {field = "sessionInfo", value = "Dict.empty"},
--         , {field = "pendingAuths", value = "Dict.empty"}
--         , {field = "??", value = "LocalUUID.initFrom4List [ 235880, 700828, 253400, 602641 ]"}
--         , {field = "pendingEmailAuths", value = "Dict.empty"}, {field = "secretCounter", value = "0"} ,
--         , {field = "sessionDict", value = "AssocList.empty"}, {field =  "pendingLogins", value = "AssocList.empty"}
--         , {field = "log", value = "[]"}]
--
--    -- updateFromFrontend
--    , ClauseInCase.init "Backend" "updateFromFrontend" "AuthToBackend authMsg" "Auth.Flow.updateFromFrontend (MagicLink.Auth.backendConfig model) clientId sessionId authMsg model" |> ClauseInCase.makeRule
--    , ClauseInCase.init "Backend" "updateFromFrontend" "AddUser realname username email" "MagicLink.Backend.addUser model clientId email realname username" |> ClauseInCase.makeRule
--    , ClauseInCase.init "Backend" "updateFromFrontend" "RequestSignUp realname username email" "MagicLink.Backend.requestSignUp model clientId realname username email" |> ClauseInCase.makeRule
--    , ClauseInCase.init "Backend" "updateFromFrontend" "GetUserDictionary" "( model, Lamdera.sendToFrontend clientId (GotUserDictionary model.users) )" |> ClauseInCase.makeRule
--
--    -- SUBSCRIPTION
--    ,                                                                                                                                   Subscription.makeRule "Backend" "Lamdera.onConnect OnConnected"
--    ]
--
--
--configRoute : List Rule
--configRoute =
--    -- 6 rules
--    [ -- ROUTE
--      Install.TypeVariant.makeRule "Route" "Route" "TermsOfServiceRoute"
--    , Install.TypeVariant.makeRule "Route" "Route" "Notes"
--    , Install.TypeVariant.makeRule "Route" "Route" "SignInRoute"
--    , Install.TypeVariant.makeRule "Route" "Route" "AdminRoute"
--    , Function.ReplaceFunction.init "Route" "decode" decode |> Function.ReplaceFunction.makeRule
--    , Function.ReplaceFunction.init "Route" "encode" encode |> Function.ReplaceFunction.makeRule
--    ]
--
--
--configView =
--    -- 8 rules
--    [ -- VIEW.MAIN
--      ClauseInCase.init "View.Main" "loadedView" "AdminRoute" adminRoute |> ClauseInCase.makeRule
--    , ClauseInCase.init "View.Main" "loadedView" "TermsOfServiceRoute" "generic model Pages.TermsOfService.view" |> ClauseInCase.makeRule
--    , ClauseInCase.init "View.Main" "loadedView" "Notes" "generic model Pages.Notes.view" |> ClauseInCase.makeRule
--    , ClauseInCase.init "View.Main" "loadedView" "SignInRoute" "generic model (\\model_ -> Pages.SignIn.view Types.LiftMsg model_.magicLinkModel |> Element.map Types.AuthFrontendMsg)" |> ClauseInCase.makeRule
--    , ClauseInCase.init "View.Main" "loadedView" "CounterPageRoute" "generic model (generic model Pages.Counter.view)" |> ClauseInCase.makeRule
--    , Function.InsertFunction.init "View.Main" "generic" generic |> Function.InsertFunction.makeRule
--
--    --
--    , Import.initSimple "View.Main" [ "Pages.SignIn", "Pages.Admin", "Pages.TermsOfService", "Pages.Notes", "User" ] |> Import.makeRule
--    , Function.ReplaceFunction.init "View.Main" "headerRow" (asOneLine headerRow) |> Function.ReplaceFunction.makeRule
--    ]
--

headerRow =
    """headerRow model = [ headerView model model.route { window = model.window, isCompact = True }, Pages.SignIn.headerView model.magicLinkModel model.route { window = model.window, isCompact = True } |> Element.map Types.AuthFrontendMsg ]"""


adminRoute =
    "if User.isAdmin model.magicLinkModel.currentUserData then generic model Pages.Admin.view else generic model Pages.Home.view"


generic =
    """generic : Types.LoadedModel -> (Types.LoadedModel -> Element Types.FrontendMsg) -> Element Types.FrontendMsg
generic model view_ =
    Element.column
        [ Element.width Element.fill, Element.height Element.fill ]
        [ Element.row [ Element.width (Element.px model.window.width), Element.Background.color View.Color.blue ]
            [ ---
              Pages.SignIn.headerView model.magicLinkModel
                model.route
                { window = model.window, isCompact = True }
                |> Element.map Types.AuthFrontendMsg
            , headerView model model.route { window = model.window, isCompact = True }
            ]
        , Element.column
            (Element.padding 20
                :: Element.scrollbarY
                :: Element.height (Element.px <| model.window.height - 95)
                :: Theme.contentAttributes
            )
            [ view_ model -- |> Element.map Types.AuthFrontendMsg
            ]
        , footer model.route model
        ]
"""


encode =
    """encode : Route -> String
encode route =
    Url.Builder.absolute
        (case route of
            HomepageRoute ->
                []

            CounterPageRoute ->
                [ "counter" ]

            TermsOfServiceRoute ->
                [ "terms" ]

            Notes ->
                [ "notes" ]

            SignInRoute ->
                [ "signin" ]

            AdminRoute ->
                [ "admin" ]
        )
        (case route of
            HomepageRoute ->
                []

            CounterPageRoute ->
                []

            TermsOfServiceRoute ->
                []

            Notes ->
                []

            SignInRoute ->
                []

            AdminRoute ->
                []
        )
"""


decode =
    """decode : Url -> Route
decode url =
    Url.Parser.oneOf
        [ Url.Parser.top |> Url.Parser.map HomepageRoute
        , Url.Parser.s "counter" |> Url.Parser.map CounterPageRoute
        , Url.Parser.s "admin" |> Url.Parser.map AdminRoute
        , Url.Parser.s "notes" |> Url.Parser.map Notes
        , Url.Parser.s "signin" |> Url.Parser.map SignInRoute
        , Url.Parser.s "tos" |> Url.Parser.map TermsOfServiceRoute
        ]
        |> (\\a -> Url.Parser.parse a url |> Maybe.withDefault HomepageRoute)
"""


--configReset : List Rule
--configReset =
--    [ Install.TypeVariant.makeRule "Types" "ToBackend" "CounterReset"
--    , Install.TypeVariant.makeRule "Types" "FrontendMsg" "Reset"
--    , ClauseInCase.init "Frontend" "updateLoaded" "Reset" "( { model | counter = 0 }, sendToBackend CounterReset )"
--        |> ClauseInCase.withInsertAfter "Increment"
--        |> ClauseInCase.makeRule
--    , ClauseInCase.init "Backend" "updateFromFrontend" "CounterReset" "( { model | counter = 0 }, broadcast (CounterNewValue 0 clientId) )" |> ClauseInCase.makeRule
--    , Function.ReplaceFunction.init "Pages.Counter" "view" viewFunction |> Function.ReplaceFunction.makeRule
--    ]


viewFunction =
    """view model =
    Html.div [ style "padding" "50px" ]
        [ Html.button [ onClick Increment ] [ text "+" ]
        , Html.div [ style "padding" "10px" ] [ Html.text (String.fromInt model.counter) ]
        , Html.button [ onClick Decrement ] [ text "-" ]
        , Html.div [] [Html.button [ onClick Reset, style "margin-top" "10px"] [ text "Reset" ]]
        ] |> Element.html   """


tryLoading1 =
    """tryLoading : LoadingModel -> ( FrontendModel, Cmd FrontendMsg )
tryLoading loadingModel =
    Maybe.map
        (\\window ->
            case loadingModel.route of
                _ ->
                    let
                        authRedirectBaseUrl =
                            let
                                initUrl =
                                    loadingModel.initUrl
                            in
                            { initUrl | query = Nothing, fragment = Nothing }
                    in
                    ( Loaded
                        { key = loadingModel.key
                        , now = loadingModel.now
                        , counter = 0
                        , window = window
                        , showTooltip = False
                        , users = Dict.empty
                        , route = loadingModel.route
                        , message = "Starting up ..."
                        }
                    , Cmd.none
                    )
        )
        loadingModel.window
        |> Maybe.withDefault ( Loading loadingModel, Cmd.none )"""


tryLoading2 =
    """tryLoading : LoadingModel -> ( FrontendModel, Cmd FrontendMsg )
tryLoading loadingModel =
    Maybe.map
        (\\window ->
            case loadingModel.route of
                _ ->
                    let
                        authRedirectBaseUrl =
                            let
                                initUrl =
                                    loadingModel.initUrl
                            in
                            { initUrl | query = Nothing, fragment = Nothing }
                    in
                    ( Loaded
                        { key = loadingModel.key
                        , now = loadingModel.now
                        , counter = 0
                        , window = window
                        , showTooltip = False
                        , magicLinkModel = Pages.SignIn.init authRedirectBaseUrl
                        , route = loadingModel.route
                        , message = "Starting up ..."
                        , users = Dict.empty
                        }
                    , Cmd.none
                    )
        )
        loadingModel.window
        |> Maybe.withDefault ( Loading loadingModel, Cmd.none )"""



-- Function to compress runs of spaces to a single space


asOneLine : String -> String
asOneLine str =
    str
        |> String.trim
        |> compressSpaces
        |> String.split "\n"
        -- |> List.filter (\s -> s /= "")
        |> String.join " "


compressSpaces : String -> String
compressSpaces string =
    userReplace " +" (\_ -> " ") string


userReplace : String -> (Regex.Match -> String) -> String -> String
userReplace userRegex replacer string =
    case Regex.fromString userRegex of
        Nothing ->
            string

        Just regex ->
            Regex.replace regex replacer string
