<#import "template.ftl" as layout>
<@layout.registrationLayout 
    displayInfo=social.displayInfo
    displayWide=(realm.password && social.providers??); section
>
    <#if section = "header">
        <link href="https://fonts.googleapis.com/css?family=Muli" rel="stylesheet"/>
        <link href="${url.resourcesPath}/img/favicon.ico" rel="icon"/>
        <script>
            const urlParams = new URLSearchParams(window.location.search);
            function toggleNewPassword() {
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
            function toggleConfirmNewPassword() {
                var x = document.getElementById("password-confirm");
                var v = document.getElementById("confirmVi");
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
    <div id="kc-form" class="box-container para <#if realm.password && social.providers??>${properties.kcContentWrapperClass!}</#if>">
        <div id="sign-in-section">
            <form id="kc-form-sign-in" class="${properties.kcFormClass!}" action="${url.registrationAction}" method="post">
                <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('email',properties.kcFormGroupErrorClass!)}">
                    <div class="${properties.kcInputWrapperClass!}">
                        <input tabindex="1" type="text" id="email" class="${properties.kcInputClass!}" name="email" placeholder="${msg("email")}" value="${(register.formData.email!'')}" autocomplete="email" required/>
                    </div>
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="email" class="${properties.kcLabelClass!}">${msg("email")}</label>
                    </div>
                </div>

                <#if !realm.registrationEmailAsUsername>
                    <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('username',properties.kcFormGroupErrorClass!)}">
                        <div class="${properties.kcInputWrapperClass!}">
                            <input tabindex="2" type="text" id="username" class="${properties.kcInputClass!}" name="username" placeholder="${msg("username")}" value="${(register.formData.username!'')}" autocomplete="username" pattern="[a-zA-Z][a-zA-Z0-9-_.]{1,14}" required/>
                        </div>
                        <div class="${properties.kcLabelWrapperClass!}">
                            <label for="username" class="${properties.kcLabelClass!}">${msg("username")}</label>
                        </div>
                    </div>
                </#if>

                <div class="divider"></div>

                <#if passwordRequired>
                    <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('password',properties.kcFormGroupErrorClass!)}">
                        <div class="${properties.kcInputWrapperClass!}">
                            <div>
                                <label class="visibility" id="v" onclick="toggleNewPassword()"><img id="vi" src="${url.resourcesPath}/img/eye-off.png"></label>
                            </div>
                            <input tabindex="3" type="password" id="password" class="${properties.kcInputClass!}" name="password" placeholder="${msg("password")}" autocomplete="new-password" required/>
                        </div>
                        <div class="${properties.kcLabelWrapperClass!}">
                            <label for="password" class="${properties.kcLabelClass!}">${msg("password")}</label>
                        </div>
                    </div>

                    <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('password-confirm',properties.kcFormGroupErrorClass!)}">
                        <div class="${properties.kcInputWrapperClass!}">
                            <div>
                                <label class="visibility" id="confirmV" onclick="toggleConfirmNewPassword()"><img id="confirmVi" src="${url.resourcesPath}/img/eye-off.png">
                            </div>
                            <input tabindex="4" type="password" id="password-confirm" class="${properties.kcInputClass!}" name="password-confirm" placeholder="${msg("passwordConfirm")}" autocomplete="new-password" required/>
                        </div>
                        <div class="${properties.kcLabelWrapperClass!}">
                            <label for="password-confirm" class="${properties.kcLabelClass!}">${msg("passwordConfirm")}</label>
                        </div>
                    </div>
                </#if>
                
                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <input tabindex="5" class="submit ${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doRegister")}"/>
                </div>
                <div id="kc-info" class="register ${properties.kcSignUpClass!}">
                    <div id="kc-info-wrapper" class="${properties.kcInfoAreaWrapperClass!}">
                        <div id="kc-registration">
                            <span><a href="${url.loginUrl}">${msg("backToLogin")?no_esc}</a></span>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
    </#if>

</@layout.registrationLayout>
