<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('password','password-confirm'); section>
    <#if section = "header">
        <script>
            const urlParams = new URLSearchParams(window.location.search);
            function toggleNewPassword() {
                var x = document.getElementById("password-new");
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
        <div id="kc-form">
            <h1 id="kc-page-title">
                ${msg("updatePasswordTitle")}
            </h1>
            <div id="update-password-section">
                <form id="kc-passwd-update-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
                    <input type="text" id="username" name="username" value="${username}" autocomplete="email" readonly="readonly" style="display:none;"/>
                    <input type="password" id="password" name="password" autocomplete="current-password" style="display:none;"/>

                    <div class="${properties.kcFormGroupClass!}">
                        <div class="${properties.kcInputWrapperClass!}">
                        <div>
                            <label class="visibility" id="v" onclick="toggleNewPassword()"><img id="vi" src="${url.resourcesPath}/img/eye-off.png"></label>
                        </div>
                            <input type="password" id="password-new" name="password-new" 
                                    class="${properties.kcInputClass!}"
                                    placeholder="${msg("passwordNew")}"
                                    autofocus autocomplete="new-password"
                            />
                        </div>
                        <div class="${properties.kcLabelWrapperClass!}">
                            <label for="password-new">${msg("passwordNew")}</label>
                        </div>
                    </div>

                    <div class="${properties.kcFormGroupClass!}">
                        <div class="${properties.kcInputWrapperClass!}">
                            <div>
                                <label class="visibility" id="confirmV" onclick="toggleConfirmNewPassword()"><img id="confirmVi" src="${url.resourcesPath}/img/eye-off.png">
                            </div>
                            <input type="password" id="password-confirm" name="password-confirm"
                                    class="${properties.kcInputClass!}"
                                    placeholder="${msg("passwordConfirm")}"
                                    autocomplete="new-password"
                            />
                        </div>
                        <div class="${properties.kcLabelWrapperClass!}">
                            <label for="password-confirm">${msg("passwordConfirm")}</label>
                        </div>
                    </div>

                    <div class="${properties.kcFormGroupClass!}">
                        <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                            <div class="${properties.kcFormOptionsWrapperClass!}">
                                <#if isAppInitiatedAction??>
                                    <div class="checkbox">
                                        <label><input type="checkbox" id="logout-sessions" name="logout-sessions" value="on" checked> ${msg("logoutOtherSessions")}</label>
                                    </div>
                                </#if>
                            </div>
                        </div>

                        <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                            <#if isAppInitiatedAction??>
                                <input class="submit ${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!}" type="submit" value="${msg("passwordConfirm")}" />
                                <button class="submit ${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!}" type="submit" name="cancel-aia" value="true" />${msg("doCancel")}</button>
                            <#else>
                                <input class="submit ${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("passwordConfirm")}" />
                            </#if>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </#if>
</@layout.registrationLayout>
