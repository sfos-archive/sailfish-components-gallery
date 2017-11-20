import QtQuick 2.0

ShaderEffect {
    property color color: "black"
    property bool opaque: !pageStack.pressed && !pageStack.busy
    // don't fade out during page orientation transition
    fragmentShader: "
            uniform bool opaque;
            uniform highp vec4 color;
            uniform lowp float qt_Opacity;
            void main() {
                gl_FragColor = vec4(color.rgb, opaque ? 1.0 : qt_Opacity);
            }
        "
}
