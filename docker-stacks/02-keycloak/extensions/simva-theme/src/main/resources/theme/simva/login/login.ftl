<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=social.displayInfo displayWide=(realm.password && social.providers??); section>
    <#if section = "header">
        <link href="https://fonts.googleapis.com/css?family=Muli" rel="stylesheet"/>
        <link href="${url.resourcesPath}/img/favicon.ico" rel="icon"/>
        <script>
            const urlParams = new URLSearchParams(window.location.search);
            const myParam = urlParams.get('token');
            const isTokenLogin = myParam != undefined;
            function togglePassword() {
                var x = document.getElementById("password");
                var v = document.getElementById("vi");
                if (x.type === "password") {
                    x.type = "text";
                    v.src = "${url.resourcesPath}/img/eye.png";
                } else {
                    x.type = "password";
                    v.src = "${url.resourcesPath}/img/eye-off.png";
                }
            }
        </script>
    <#elseif section = "form">
    <div>
        <img class="logo" src="${url.resourcesPath}/img/simva-logo.png" alt="Simva">
    </div>
    <div id="kc-form" class="box-container para <#if realm.password && social.providers??>${properties.kcContentWrapperClass!}</#if>">
        <div id="normal-login">
            <script>
                if(isTokenLogin){
                    var normalLogin = document.getElementById("normal-login");
                    normalLogin.parentElement.removeChild(normalLogin);
                }
            </script>
            <div id="kc-form-wrapper" <#if realm.password && social.providers??>class="${properties.kcFormSocialAccountContentClass!} ${properties.kcFormSocialAccountClass!}"</#if>>
                <#if realm.password>
                <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
                    <div class="${properties.kcFormGroupClass!}">
                        <#if usernameEditDisabled??>
                            <input tabindex="1" id="username" class="login-field" name="username" value="${(login.username!'')}" type="text" disabled />
                        <#else>
                            <input tabindex="1" id="username" class="login-field" name="username" value="${(login.username!'')}"  type="text" autofocus autocomplete="off" />
                        </#if>
                    </div>

                    <div class="${properties.kcFormGroupClass!}">
                        <div>
                            <label class="visibility" id="v" onclick="togglePassword()"><img id="vi" src="${url.resourcesPath}/img/eye-off.png"></label>
                        </div>
                        <input tabindex="2" id="password" class="login-field" name="password" type="password" autocomplete="off" />
                    </div>

                    <div class="${properties.kcFormGroupClass!} ${properties.kcFormSettingClass!}">
                        <div id="kc-form-options" class="refor">
                            <#if realm.rememberMe && !usernameEditDisabled??>
                                <div class="checkbox">
                                    <label>
                                        <#if login.rememberMe??>
                                            <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" checked> ${msg("rememberMe")}
                                        <#else>
                                            <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox"> ${msg("rememberMe")}
                                        </#if>
                                    </label>
                                </div>
                            </#if>
                            <div class="${properties.kcFormOptionsWrapperClass!} forgot">
                                <#if realm.resetPasswordAllowed>
                                    <span><a tabindex="5" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></span>
                                </#if>
                            </div>

                        </div>

                        <div id="kc-form-buttons" class="${properties.kcFormGroupClass!}">
                            <input type="hidden" id="id-hidden-input" name="credentialId" />
                            <input tabindex="4" class="submit ${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" name="login" id="kc-login" type="submit" value="${msg("doLogIn")}"/>
                        </div>
                    </div>
                </form>
                </#if>
            </div>
            <#if realm.password && social.providers??>
                <div id="kc-social-providers" class="${properties.kcFormSocialAccountContentClass!} ${properties.kcFormSocialAccountClass!}">
                    <ul class="${properties.kcFormSocialAccountListClass!} <#if social.providers?size gt 4>${properties.kcFormSocialAccountDoubleListClass!}</#if>">
                        <#list social.providers as p>
                            <li class="${properties.kcFormSocialAccountListLinkClass!}"><a href="${p.loginUrl}" id="zocial-${p.alias}" class="zocial ${p.providerId}"> <span>${p.displayName}</span></a></li>
                        </#list>
                    </ul>
                </div>
            </#if>
            
            <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
                <div id="kc-info" class="register ${properties.kcSignUpClass!}">
                    <div id="kc-info-wrapper" class="${properties.kcInfoAreaWrapperClass!}">
                        <div id="kc-registration">
                            <span>${msg("noAccount")} <a tabindex="6" href="${url.registrationUrl}">${msg("doRegister")}</a></span>
                        </div>
                    </div>
                </div>
            </#if>
        </div>
        <div id="token-login">
            <div id="kc-form-wrapper" <#if realm.password && social.providers??>class="${properties.kcFormSocialAccountContentClass!} ${properties.kcFormSocialAccountClass!}"</#if>>
                <#if realm.password>
                <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">

                    <div class="${properties.kcFormGroupClass!}">
                        <input tabindex="1" id="username" class="login-field" name="username" value="${(login.username!'')}"  type="text" autofocus autocomplete="off" />
                        <input tabindex="2" id="password" class="login-field" name="password" type="hidden" autocomplete="off" />
                    </div>

                    <div class="${properties.kcFormGroupClass!} ${properties.kcFormSettingClass!}">
                        <div id="kc-form-options" class="refor">
                            <#if realm.rememberMe && !usernameEditDisabled??>
                                <div class="checkbox">
                                    <label>
                                        <#if login.rememberMe??>
                                            <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" checked> ${msg("rememberMe")}
                                        <#else>
                                            <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox"> ${msg("rememberMe")}
                                        </#if>
                                    </label>
                                </div>
                            </#if>
                            </div>
                        </div>
                        <div id="kc-form-buttons" class="${properties.kcFormGroupClass!}">
                            <input type="hidden" id="id-hidden-input" name="credentialId" />
                            <input tabindex="4" class="submit ${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" name="login" id="kc-login" type="submit" value="${msg("doLogIn")}"/>
                        </div>
                    </div>
                </form>
                </#if>
            </div>
            <script>
                if(!isTokenLogin){
                    var tokenLogin = document.getElementById("token-login");
                    tokenLogin.parentElement.removeChild(tokenLogin);
                }else{
                    var username = document.getElementById("username");
                    var password = document.getElementById("password");
                    username.oninput = function(){
                        password.value = username.value;
                    };

                }
            </script>
        </div>
    </div>
    </#if>

</@layout.registrationLayout>
