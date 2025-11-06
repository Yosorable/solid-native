//
//  View+Modifiers.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import JavaScriptCore
import SwiftUI

extension View {
    func solidNativeViewModifiers(
        mods: [[String: JSValue?]],
        keys: [String],
        owner: SolidNativeView? = nil
    ) -> some View {
        modifier(
            SolidNativeViewModifiers(
                mods: mods,
                keys: keys,
                owner: owner
            )
        )
    }
}
struct SolidNativeViewModifiers: ViewModifier {
    var mods: [[String: JSValue?]]
    var keys: [String]
    weak var owner: SolidNativeView?

    func body(content: Content) -> some View {
        var view = AnyView(content)
        for mod in mods {
            // for (key, value) in mod {
            for key in keys {
                let jsValue = mod[key] as? JSValue
                guard let value = jsValue?.toObject() else { continue }
                switch key {
                case "padding":
                    if value is Bool {
                        view = AnyView(view.padding())
                    } else if let padding = value as? CGFloat {
                        view = AnyView(view.padding(padding))
                    } else if let padding = value as? [String: CGFloat] {

                        let top: CGFloat = padding["top"] ?? 0
                        let leading: CGFloat = padding["leading"] ?? 0
                        let bottom: CGFloat = padding["bottom"] ?? 0
                        let trailing: CGFloat = padding["trailing"] ?? 0
                        let horizontal: CGFloat = padding["horizontal"] ?? 0
                        let vertical: CGFloat = padding["vertical"] ?? 0
                        let all: CGFloat = padding["all"] ?? 0

                        let edgeInsets = EdgeInsets(
                            top: all != 0
                                ? all : vertical != 0 ? vertical : top,
                            leading: all != 0
                                ? all : horizontal != 0 ? horizontal : leading,
                            bottom: all != 0
                                ? all : vertical != 0 ? vertical : bottom,
                            trailing: all != 0
                                ? all : horizontal != 0 ? horizontal : trailing
                        )

                        view = AnyView(view.padding(edgeInsets))

                    }
                case "border":
                    if let border = value as? [String: Any] {
                        let color =
                            getColor(border["color"]) as Color? ?? Color.black
                        let width = border["width"] as? CGFloat ?? 1.0
                        view = AnyView(view.border(color, width: width))
                    }

                case "tag":
                    if let tag = value as? Int {
                        view = AnyView(view.tag(tag))
                    } else if let tag = value as? String {
                        view = AnyView(view.tag(tag))
                    }

                case "foregroundStyle":
                    if let color = getColor(value) as Color? {
                        if #available(iOS 15.0, *) {
                            view = AnyView(view.foregroundStyle(color))
                        } else {

                        }
                    } else if let color = value as? [Any] {
                        let colors = getColors(color) as [Color]
                        switch color.count {
                        case 1:
                            if #available(iOS 15.0, *) {
                                view = AnyView(view.foregroundStyle(colors[0]))
                            }
                        case 2:
                            if #available(iOS 15.0, *) {
                                view = AnyView(
                                    view.foregroundStyle(colors[0], colors[1])
                                )
                            }
                        case 3:
                            if #available(iOS 15.0, *) {
                                view = AnyView(
                                    view.foregroundStyle(
                                        colors[0],
                                        colors[1],
                                        colors[2]
                                    )
                                )
                            }
                        default:
                            break
                        }
                    }
                case "background":
                    if jsValue?.isObject == true,
                        jsValue?.hasProperty("id") ?? false,
                        let id = jsValue?.forProperty("id").toString()
                    {
                        let node = SolidNativeCore.shared.renderer.viewManager
                            .getViewById(id)
                        owner?.indirectChildren.append(node)
                        view = AnyView(
                            view.background {
                                node.render()
                            }
                        )
                    } else if let color = getColor(value) as Color? {
                        view = AnyView(view.background(color))
                    }
                case "overlay":
                    if jsValue?.isObject == true,
                        let id = jsValue?.forProperty("id").toString()
                    {
                        let node = SolidNativeCore.shared.renderer.viewManager
                            .getViewById(id)
                        owner?.indirectChildren.append(node)
                        view = AnyView(
                            view.overlay {
                                node.render()
                            }
                        )
                    } else if let color = getColor(value) as Color? {
                        view = AnyView(view.overlay(color))
                    }
                case "rotationEffect":
                    if let rotation = value as? [String: CGFloat] {
                        if let degrees = rotation["degrees"] {
                            view = AnyView(
                                view.rotationEffect(.degrees(Double(degrees)))
                            )
                        } else if let radians = rotation["radians"] {
                            view = AnyView(
                                view.rotationEffect(.radians(Double(radians)))
                            )
                        }
                    }
                case "scaleEffect":
                    if let scale = value as? CGFloat {
                        view = AnyView(view.scaleEffect(scale))
                    }
                case "shadow":
                    if let shadow = value as? [String: Any] {
                        let color =
                            getColor(shadow["color"]) as Color? ?? Color.black
                        let radius = shadow["radius"] as? CGFloat ?? 1.0
                        let x = shadow["x"] as? CGFloat ?? 0.0
                        let y = shadow["y"] as? CGFloat ?? 0.0
                        view = AnyView(
                            view.shadow(
                                color: color,
                                radius: radius,
                                x: x,
                                y: y
                            )
                        )
                    }
                case "opacity":
                    if let opacity = value as? CGFloat {
                        view = AnyView(view.opacity(opacity))
                    }
                case "blur":
                    if let blur = value as? CGFloat {
                        view = AnyView(view.blur(radius: blur))
                    }
                case "saturation":
                    if let sat = value as? Double {
                        view = AnyView(view.saturation(sat))
                    }
                case "grayscale":
                    if let gs = value as? Double {
                        view = AnyView(view.grayscale(gs))
                    }
                case "brightness":
                    if let brightness = value as? Double {
                        view = AnyView(view.brightness(brightness))
                    }
                case "contrast":
                    if let contrast = value as? Double {
                        view = AnyView(view.contrast(contrast))
                    }
                case "hidden":
                    if let hidden = value as? Bool {
                        if hidden == true {
                            view = AnyView(view.hidden())
                        }
                    }
                case "blendMode":
                    if let blendMode = value as? String {
                        switch blendMode {
                        case "color":
                            view = AnyView(view.blendMode(.color))
                        case "colorBurn":
                            view = AnyView(view.blendMode(.colorBurn))
                        case "colorDodge":
                            view = AnyView(view.blendMode(.colorDodge))
                        case "darken":
                            view = AnyView(view.blendMode(.darken))
                        case "difference":
                            view = AnyView(view.blendMode(.difference))
                        case "exclusion":
                            view = AnyView(view.blendMode(.exclusion))
                        case "hardLight":
                            view = AnyView(view.blendMode(.hardLight))
                        case "hue":
                            view = AnyView(view.blendMode(.hue))
                        case "lighten":
                            view = AnyView(view.blendMode(.lighten))
                        case "luminosity":
                            view = AnyView(view.blendMode(.luminosity))
                        case "multiply":
                            view = AnyView(view.blendMode(.multiply))
                        case "overlay":
                            view = AnyView(view.blendMode(.overlay))
                        case "saturation":
                            view = AnyView(view.blendMode(.saturation))
                        case "screen":
                            view = AnyView(view.blendMode(.screen))
                        case "softLight":
                            view = AnyView(view.blendMode(.softLight))
                        case "sourceAtop":
                            view = AnyView(view.blendMode(.sourceAtop))
                        case "destinationOver":
                            view = AnyView(view.blendMode(.destinationOver))
                        case "destinationOut":
                            view = AnyView(view.blendMode(.destinationOut))
                        case "plusDarker":
                            view = AnyView(view.blendMode(.plusDarker))
                        case "plusLighter":
                            view = AnyView(view.blendMode(.plusLighter))
                        case "normal":
                            view = AnyView(view.blendMode(.normal))
                        default:
                            break
                        }
                    }
                case "frame":
                    if let frame = value as? [String: Any] {
                        let width = anyToCGFloat(frame["width"])
                        let height = anyToCGFloat(frame["height"])
                        let alignment =
                            anyToAlignment(frame["alignment"]) ?? .center
                        if let w = width, let h = height {
                            view = AnyView(
                                view.frame(
                                    width: w,
                                    height: h,
                                    alignment: alignment
                                )
                            )
                        } else if let w = width {
                            view = AnyView(
                                view.frame(width: w, alignment: alignment)
                            )
                        } else if let h = height {
                            view = AnyView(
                                view.frame(height: h, alignment: alignment)
                            )
                        } else {
                            let minWidth = anyToCGFloat(frame["minWidth"])
                            let idealWidth = anyToCGFloat(frame["idealWidth"])
                            let maxWidth = anyToCGFloat(frame["maxWidth"])
                            let minHeight = anyToCGFloat(frame["minHeight"])
                            let idealHeight = anyToCGFloat(frame["idealHeight"])
                            let maxHeight = anyToCGFloat(frame["maxHeight"])

                            view = AnyView(
                                view.frame(
                                    minWidth: minWidth,
                                    idealWidth: idealWidth,
                                    maxWidth: maxWidth,
                                    minHeight: minHeight,
                                    idealHeight: idealHeight,
                                    maxHeight: maxHeight,
                                    alignment: alignment
                                )
                            )
                        }
                    }
                case "zIndex":
                    if let zIndex = value as? Double {
                        view = AnyView(view.zIndex(zIndex))
                    }

                case "labelIsHidden":
                    if let isHidden = value as? Bool, isHidden == true {
                        view = AnyView(view.labelsHidden())
                    }
                // Currently only supports text mask
                case "mask":
                    if let mask = value as? String {
                        if #available(iOS 15.0, *) {
                            view = AnyView(
                                view.mask({
                                    Text(mask)
                                })
                            )
                        }
                    }
                // Currently only supports direct mapping to shapes
                case "clipShape":
                    if let clipShape = value as? String {
                        switch clipShape {
                        case "circle":
                            view = AnyView(view.clipShape(Circle()))
                        case "roundedRectangle":
                            view = AnyView(
                                view.clipShape(
                                    RoundedRectangle(cornerRadius: 10)
                                )
                            )
                        case "capsule":
                            view = AnyView(view.clipShape(Capsule()))
                        case "ellipse":
                            view = AnyView(view.clipShape(Ellipse()))
                        case "rectangle":
                            view = AnyView(view.clipShape(Rectangle()))
                        default:
                            break
                        }
                    } else if let clipShape = value as? [String: Any] {
                        if let shape = clipShape["shape"] as? String {
                            switch shape {
                            case "circle":
                                view = AnyView(view.clipShape(Circle()))
                            case "roundedRectangle":
                                if let cornerRadius = clipShape["cornerRadius"]
                                    as? CGFloat
                                {
                                    view = AnyView(
                                        view.clipShape(
                                            RoundedRectangle(
                                                cornerRadius: cornerRadius
                                            )
                                        )
                                    )
                                }
                            case "capsule":
                                view = AnyView(view.clipShape(Capsule()))
                            case "ellipse":
                                view = AnyView(view.clipShape(Ellipse()))
                            case "rectangle":
                                view = AnyView(view.clipShape(Rectangle()))
                            default:
                                break
                            }
                        }
                    }
                case "environment":
                    if let obj = value as? [String: Any] {
                        for (key, value) in obj {
                            switch key {
                            case "colorScheme":
                                if let colorScheme = value as? String {
                                    if #available(iOS 15.0, *) {
                                        switch colorScheme {
                                        case "light":
                                            view = AnyView(
                                                view.environment(
                                                    \.colorScheme,
                                                    .light
                                                )
                                            )
                                        case "dark":
                                            view = AnyView(
                                                view.environment(
                                                    \.colorScheme,
                                                    .dark
                                                )
                                            )
                                        default:
                                            break
                                        }
                                    }
                                }
                            default:
                                break
                            }
                        }
                    }
                case "symbolRenderingMode":
                    if let renderingMode = value as? String {
                        if #available(iOS 15.0, *) {
                            switch renderingMode {
                            case "monochrome":
                                view = AnyView(
                                    view.symbolRenderingMode(.monochrome)
                                )
                            case "hierarchical":
                                view = AnyView(
                                    view.symbolRenderingMode(.hierarchical)
                                )
                            case "multicolor":
                                view = AnyView(
                                    view.symbolRenderingMode(.multicolor)
                                )
                            case "palette":
                                view = AnyView(
                                    view.symbolRenderingMode(.palette)
                                )
                            default:
                                break
                            }
                        }
                    }
                case "imageScale":
                    if let scale = value as? String {
                        switch scale {
                        case "small":
                            view = AnyView(view.imageScale(.small))
                        case "medium":
                            view = AnyView(view.imageScale(.medium))
                        case "large":
                            view = AnyView(view.imageScale(.large))
                        default:
                            break
                        }
                    }

                case "fontSize":
                    if let fontSize = value as? CGFloat {
                        view = AnyView(view.font(.system(size: fontSize)))
                    }

                case "fontWeight":
                    if let fontWeight = value as? String {
                        if #available(iOS 16.0, *) {
                            switch fontWeight {
                            case "ultralight":
                                view = AnyView(view.fontWeight(.ultraLight))
                            case "thin":
                                view = AnyView(view.fontWeight(.thin))
                            case "light":
                                view = AnyView(view.fontWeight(.light))
                            case "regular":
                                view = AnyView(view.fontWeight(.regular))
                            case "medium":
                                view = AnyView(view.fontWeight(.medium))
                            case "semibold":
                                view = AnyView(view.fontWeight(.semibold))
                            case "bold":
                                view = AnyView(view.fontWeight(.bold))
                            case "heavy":
                                view = AnyView(view.fontWeight(.heavy))
                            case "black":
                                view = AnyView(view.fontWeight(.black))
                            default:
                                break
                            }
                        }
                    }

                case "font":
                    if let font = value as? String {
                        switch font {
                        case "caption":
                            view = AnyView(view.font(.caption))
                        case "caption2":
                            if #available(iOS 14.0, *) {
                                view = AnyView(view.font(.caption2))
                            }
                        case "footnote":
                            view = AnyView(view.font(.footnote))
                        case "body":
                            view = AnyView(view.font(.body))
                        case "callout":
                            view = AnyView(view.font(.callout))
                        case "subheadline":
                            view = AnyView(view.font(.subheadline))
                        case "headline":
                            view = AnyView(view.font(.headline))
                        case "title":
                            view = AnyView(view.font(.title))
                        case "title2":
                            if #available(iOS 14.0, *) {
                                view = AnyView(view.font(.title2))
                            }
                        case "title3":
                            if #available(iOS 14.0, *) {
                                view = AnyView(view.font(.title3))
                            }
                        case "largeTitle":
                            view = AnyView(view.font(.largeTitle))
                        default:
                            break
                        }
                    }

                case "bold":
                    if let bold = value as? Bool {
                        if #available(iOS 16.0, *) {
                            view = AnyView(view.bold(bold))
                        }
                    }

                case "italic":
                    if let italic = value as? Bool {
                        if #available(iOS 16.0, *) {
                            view = AnyView(view.italic(italic))
                        }
                    }

                case "strikethrough":
                    if #available(iOS 16.0, *) {
                        if let isActive = value as? Bool {
                            print(isActive)
                            view = AnyView(view.strikethrough(isActive))
                        } else if let strikethrough = value as? [String: Any] {
                            let isActive =
                                strikethrough["isActive"] as? Bool ?? false
                            let color =
                                getColor(strikethrough["color"]) as Color?
                            let pattern = strikethrough["pattern"] as? String

                            let patternStyle: Text.LineStyle.Pattern
                            switch pattern {
                            case "solid":
                                patternStyle = .solid
                            case "dot":
                                patternStyle = .dot
                            case "dash":
                                patternStyle = .dash
                            case "dashDot":
                                patternStyle = .dashDot
                            case "dashDotDot":
                                patternStyle = .dashDotDot
                            default:
                                patternStyle = .solid
                            }
                            view = AnyView(
                                view.strikethrough(
                                    isActive,
                                    pattern: patternStyle,
                                    color: color
                                )
                            )
                        }
                    }

                case "underline":
                    if #available(iOS 16.0, *) {
                        if let isActive = value as? Bool {
                            view = AnyView(view.underline(isActive))
                        } else if let strikethrough = value as? [String: Any] {
                            let isActive =
                                strikethrough["isActive"] as? Bool ?? false
                            let color =
                                getColor(strikethrough["color"]) as Color?
                            let pattern = strikethrough["pattern"] as? String

                            let patternStyle: Text.LineStyle.Pattern
                            switch pattern {
                            case "solid":
                                patternStyle = .solid
                            case "dot":
                                patternStyle = .dot
                            case "dash":
                                patternStyle = .dash
                            case "dashDot":
                                patternStyle = .dashDot
                            case "dashDotDot":
                                patternStyle = .dashDotDot
                            default:
                                patternStyle = .solid
                            }
                            view = AnyView(
                                view.underline(
                                    isActive,
                                    pattern: patternStyle,
                                    color: color
                                )
                            )
                        }
                    }

                case "lineLimit":
                    view = AnyView(view.lineLimit(value as? Int))
                case "truncationMode":
                    if let tm = value as? String {
                        if tm == "head" {
                            view = AnyView(view.truncationMode(.head))
                        } else if tm == "middle" {
                            view = AnyView(view.truncationMode(.middle))
                        } else if tm == "tail" {
                            view = AnyView(view.truncationMode(.tail))
                        }
                    }
                case "tint":
                    if let color = getColor(value) as Color? {
                        if #available(iOS 16.0, *) {
                            view = AnyView(view.tint(color))
                        } else {
                            view = AnyView(view.accentColor(color))
                        }
                    }

                case "cornerRadius":
                    if let cornerRadius = value as? CGFloat {
                        view = AnyView(view.cornerRadius(cornerRadius))
                    }

                case "buttonStyle":
                    if let buttonStyle = value as? String {
                        switch buttonStyle {
                        case "borderless":
                            view = AnyView(view.buttonStyle(.borderless))
                        case "bordered":
                            if #available(iOS 15.0, *) {
                                view = AnyView(view.buttonStyle(.bordered))
                            }
                        case "borderedProminent":
                            if #available(iOS 15.0, *) {
                                view = AnyView(
                                    view.buttonStyle(.borderedProminent)
                                )
                            }
                        case "plain":
                            view = AnyView(view.buttonStyle(.plain))
                        default:
                            break
                        }
                    }

                case "presentationCornerRadius":
                    if let cornerRadius = value as? CGFloat {
                        if #available(iOS 16.4, *) {
                            view = AnyView(
                                view.presentationCornerRadius(cornerRadius)
                            )
                        }
                    }

                case "presentationDetents":
                    if let presentationDetents = value as? [Any] {
                        if #available(iOS 16.0, *) {
                            var detents: Set<PresentationDetent> = []
                            for detent in presentationDetents {
                                if let detent = detent as? String {
                                    switch detent {
                                    case "medium":
                                        detents.insert(.medium)
                                    case "large":
                                        detents.insert(.large)
                                    default:
                                        break
                                    }
                                } else if let detent = detent as? [String: Any]
                                {
                                    if let fraction = detent["fraction"]
                                        as? CGFloat
                                    {
                                        detents.insert(.fraction(fraction))
                                    } else if let height = detent["height"]
                                        as? CGFloat
                                    {
                                        detents.insert(.height(height))
                                    }
                                }
                            }
                            view = AnyView(view.presentationDetents(detents))
                        }
                    }

                case "sensoryFeedback":
                    if let sensoryFeedback = value as? [String: Any],
                        let feedback = sensoryFeedback["feedback"] as? String,
                        let trigger = sensoryFeedback["trigger"]
                            as? any Equatable
                    {
                        if #available(iOS 17.0, *) {
                            switch feedback {
                            case "warning":
                                view = AnyView(
                                    view.sensoryFeedback(
                                        .warning,
                                        trigger: trigger
                                    )
                                )
                            case "error":
                                view = AnyView(
                                    view.sensoryFeedback(
                                        .error,
                                        trigger: trigger
                                    )
                                )
                            case "success":
                                view = AnyView(
                                    view.sensoryFeedback(
                                        .success,
                                        trigger: trigger
                                    )
                                )
                            case "alignment":
                                view = AnyView(
                                    view.sensoryFeedback(
                                        .alignment,
                                        trigger: trigger
                                    )
                                )
                            case "decrease":
                                view = AnyView(
                                    view.sensoryFeedback(
                                        .decrease,
                                        trigger: trigger
                                    )
                                )
                            case "impact":
                                view = AnyView(
                                    view.sensoryFeedback(
                                        .impact,
                                        trigger: trigger
                                    )
                                )
                            case "increase":
                                view = AnyView(
                                    view.sensoryFeedback(
                                        .increase,
                                        trigger: trigger
                                    )
                                )
                            case "levelChange":
                                view = AnyView(
                                    view.sensoryFeedback(
                                        .levelChange,
                                        trigger: trigger
                                    )
                                )
                            case "selection":
                                view = AnyView(
                                    view.sensoryFeedback(
                                        .selection,
                                        trigger: trigger
                                    )
                                )
                            case "start":
                                view = AnyView(
                                    view.sensoryFeedback(
                                        .start,
                                        trigger: trigger
                                    )
                                )
                            case "stop":
                                view = AnyView(
                                    view.sensoryFeedback(
                                        .stop,
                                        trigger: trigger
                                    )
                                )
                            default:
                                break
                            }
                        }
                    }

                case "listStyle":
                    if let listStyle = value as? String {
                        switch listStyle {
                        case "grouped":
                            view = AnyView(view.listStyle(.grouped))
                        case "inset":
                            if #available(iOS 14.0, *) {
                                view = AnyView(view.listStyle(.inset))
                            }
                        case "insetGrouped":
                            if #available(iOS 14.0, *) {
                                view = AnyView(view.listStyle(.insetGrouped))
                            }
                        case "sidebar":
                            if #available(iOS 14.0, *) {
                                view = AnyView(view.listStyle(.sidebar))
                            }
                        case "plain":
                            if #available(iOS 14.0, *) {
                                view = AnyView(view.listStyle(.plain))
                            }

                        default:
                            break
                        }
                    }

                case "scrollDisabled":
                    if let scrollDisabled = value as? Bool {
                        if scrollDisabled {
                            if #available(iOS 16.0, *) {
                                view = AnyView(
                                    view.scrollDisabled(scrollDisabled)
                                )
                            }
                        }
                    }

                case "textFieldStyle":
                    if let textFieldStyle = value as? String {
                        switch textFieldStyle {
                        case "roundedBorder":
                            view = AnyView(view.textFieldStyle(.roundedBorder))
                        case "plain":
                            view = AnyView(view.textFieldStyle(.plain))
                        default:
                            break
                        }
                    }

                case "pickerStyle":
                    if let pickerStyle = value as? String {
                        switch pickerStyle {
                        case "wheel":
                            if #available(iOS 14.0, *) {
                                view = AnyView(view.pickerStyle(.wheel))
                            }
                        case "segmented":
                            if #available(iOS 14.0, *) {
                                view = AnyView(view.pickerStyle(.segmented))
                            }
                        case "menu":
                            if #available(iOS 14.0, *) {
                                view = AnyView(view.pickerStyle(.menu))
                            }
                        default:
                            break
                        }
                    }

                case "position":
                    if let position = value as? [String: Any] {
                        if let x = position["x"] as? CGFloat,
                            let y = position["y"] as? CGFloat
                        {
                            view = AnyView(view.position(x: x, y: y))
                        }
                    }

                case "offset":
                    if let offset = value as? [String: Any] {
                        if let x = offset["x"] as? CGFloat,
                            let y = offset["y"] as? CGFloat
                        {
                            view = AnyView(view.offset(x: x, y: y))
                        }
                    }

                case "contentTransition":
                    if let transition = value as? String {
                        switch transition {
                        // identity, interpolate, opacity, symbolEffect, numericText
                        case "identity":
                            if #available(iOS 16.0, *) {
                                view = AnyView(
                                    view.contentTransition(.identity)
                                )
                            }
                        case "interpolate":
                            if #available(iOS 16.0, *) {
                                view = AnyView(
                                    view.contentTransition(.interpolate)
                                )
                            }
                        case "opacity":
                            if #available(iOS 16.0, *) {
                                view = AnyView(view.contentTransition(.opacity))
                            }
                        case "symbolEffect":
                            if #available(iOS 17.0, *) {
                                view = AnyView(
                                    view.contentTransition(.symbolEffect)
                                )
                            }
                        case "numericText":
                            if #available(iOS 16.0, *) {
                                view = AnyView(
                                    view.contentTransition(
                                        .numericText(countsDown: false)
                                    )
                                )
                            }
                        default:
                            break
                        }
                    }

                case "animation":
                    if let animation = value as? [String: Any] {
                        print("ani")
                        if let type = animation["type"] as? String {
                            if let value = animation["value"] as? any Equatable
                            {
                                switch type {
                                case "bouncy":
                                    view = AnyView(
                                        view.animation(.bouncy, value: value)
                                    )
                                case "easeIn":
                                    view = AnyView(
                                        view.animation(.easeIn, value: value)
                                    )
                                case "easeOut":
                                    view = AnyView(
                                        view.animation(.easeOut, value: value)
                                    )
                                case "easeInOut":
                                    view = AnyView(
                                        view.animation(.easeInOut, value: value)
                                    )
                                case "linear":
                                    view = AnyView(
                                        view.animation(.linear, value: value)
                                    )
                                case "spring":
                                    view = AnyView(
                                        view.animation(.spring, value: value)
                                    )
                                case "smooth":
                                    view = AnyView(
                                        view.animation(.smooth, value: value)
                                    )
                                case "interactiveSpring":
                                    view = AnyView(
                                        view.animation(
                                            .interactiveSpring,
                                            value: value
                                        )
                                    )
                                case "default":
                                    view = AnyView(
                                        view.animation(.default, value: value)
                                    )
                                default:
                                    break
                                }
                            }
                        }
                    }

                case "textContentType":
                    if let textContentType = value as? String {
                        if #available(iOS 15.0, *) {
                            view = AnyView(
                                view.textContentType(
                                    UITextContentType(rawValue: textContentType)
                                )
                            )
                        }
                    }

                case "keyboardType":
                    if let keyboardType = value as? String {
                        if #available(iOS 15.0, *) {
                            switch keyboardType {
                            case "numberPad":
                                view = AnyView(view.keyboardType(.numberPad))

                            case "phonePad":
                                view = AnyView(view.keyboardType(.phonePad))

                            case "namePhonePad":
                                view = AnyView(view.keyboardType(.namePhonePad))

                            case "emailAddress":
                                view = AnyView(view.keyboardType(.emailAddress))

                            case "decimalPad":
                                view = AnyView(view.keyboardType(.decimalPad))

                            case "twitter":
                                view = AnyView(view.keyboardType(.twitter))

                            case "webSearch":
                                view = AnyView(view.keyboardType(.webSearch))

                            case "asciiCapableNumberPad":
                                view = AnyView(
                                    view.keyboardType(.asciiCapableNumberPad)
                                )

                            case "asciiCapable":
                                view = AnyView(view.keyboardType(.asciiCapable))

                            case "numbersAndPunctuation":
                                view = AnyView(
                                    view.keyboardType(.numbersAndPunctuation)
                                )

                            case "URL":
                                view = AnyView(view.keyboardType(.URL))

                            case "default":
                                view = AnyView(view.keyboardType(.default))

                            default:
                                break
                            }
                        }
                    }

                case "autocorrectionDisabled":
                    if let autocorrectionDisabled = value as? Bool {
                        if #available(iOS 15.0, *) {
                            view = AnyView(
                                view.autocorrectionDisabled(
                                    autocorrectionDisabled
                                )
                            )
                        }
                    }

                case "textInputAutocapitalization":
                    if let autocapitalization = value as? String {
                        if #available(iOS 15.0, *) {
                            switch autocapitalization {
                            case "never":
                                view = AnyView(
                                    view.textInputAutocapitalization(.never)
                                )
                            case "words":
                                view = AnyView(
                                    view.textInputAutocapitalization(.words)
                                )
                            case "sentences":
                                view = AnyView(
                                    view.textInputAutocapitalization(.sentences)
                                )
                            case "characters":
                                view = AnyView(
                                    view.textInputAutocapitalization(
                                        .characters
                                    )
                                )
                            default:
                                break
                            }
                        }
                    }

                case "onAppear":
                    view = AnyView(
                        view.onAppear {
                            jsValue?.call(withArguments: [])
                        }
                    )

                case "onDisappear":
                    view = AnyView(
                        view.onDisappear {
                            jsValue?.call(withArguments: [])
                        }
                    )

                case "onTapGesture":
                    var perform: JSValue? = nil
                    var cnt: Int? = nil

                    if let jv = jsValue {
                        cnt = jv.forProperty("count").toObject() as? Int
                        perform = cnt == nil ? jv : jv.forProperty("perform")

                    }
                    if let cnt = cnt, let perform = perform {
                        view = AnyView(
                            view.onTapGesture(count: cnt) {
                                perform.call(withArguments: [])
                            }
                        )
                    } else if let perform = jsValue {
                        view = AnyView(
                            view.onTapGesture {
                                perform.call(withArguments: [])
                            }
                        )
                    }

                case "onLongPressGesture":
                    var perform: JSValue? = nil
                    var minimumDuration: Double? = nil
                    var maximumDistance: Double? = nil
                    var onPressingChanged: JSValue? = nil

                    if let jv = jsValue {
                        minimumDuration =
                            jv.forProperty("minimumDuration").toObject()
                            as? Double
                        maximumDistance =
                            jv.forProperty("maximumDistance").toObject()
                            as? Double
                        onPressingChanged = jv.forProperty("onPressingChanged")
                        perform = jv.forProperty("perform")
                        if perform?.isUndefined ?? true {
                            perform = nil
                        }
                        if onPressingChanged?.isUndefined ?? true {
                            onPressingChanged = nil
                        }
                        if perform == nil && minimumDuration == nil
                            && maximumDistance == nil
                            && onPressingChanged == nil
                        {
                            perform = jv
                        }
                    }
                    if let perform = perform {
                        view = AnyView(
                            view.onLongPressGesture(
                                minimumDuration: minimumDuration ?? 0.5,
                                maximumDistance: maximumDistance ?? 10,
                                perform: {
                                    perform.call(withArguments: [])
                                },
                                onPressingChanged: onPressingChanged == nil
                                    ? nil
                                    : { val in
                                        onPressingChanged?.call(withArguments: [
                                            val
                                        ])
                                    }
                            )
                        )
                    }

                case "dragGesture":
                    view = AnyView(
                        view.gesture(
                            DragGesture()
                                .onChanged { val in
                                    if jsValue?.hasProperty("onChanged") == true
                                    {
                                        jsValue?.forProperty("onChanged").call(
                                            withArguments: [val.toDictionary()])
                                    }
                                }
                                .onEnded { val in
                                    if jsValue?.hasProperty("onEnded") == true {
                                        jsValue?.forProperty("onEnded").call(
                                            withArguments: [val.toDictionary()])
                                    }
                                }
                        )
                    )
                case "navigationTitle":
                    if let title = value as? String {
                        view = AnyView(view.navigationTitle(Text(title)))
                    }
                case "navigationBarTitleDisplayMode":
                    let md = value as? String
                    view = AnyView(
                        view.navigationBarTitleDisplayMode(
                            md == "inline"
                                ? .inline
                                : (md == "large" ? .large : .automatic)
                        )
                    )

                case "swipeActions":
                    let addSAFunc = { (_ v: AnyView, _ cfg: JSValue) in
                        guard
                            let contentId = cfg.forProperty("content")
                                .forProperty("id").toString()
                        else {
                            return v
                        }
                        var allowsFullSwipe = true
                        var edge = HorizontalEdge.trailing

                        if let afs = cfg.forProperty("allowsFullSwipe"),
                            afs.isBoolean
                        {
                            allowsFullSwipe = afs.toBool()
                        }

                        if let eg = cfg.forProperty("edge").toString() {
                            if eg == "leading" {
                                edge = .leading
                            } else if eg == "trailing" {
                                edge = .trailing
                            }
                        }
                        let node = SolidNativeCore.shared.renderer.viewManager
                            .getViewById(contentId)
                        owner?.indirectChildren.append(node)
                        return AnyView(
                            v.swipeActions(
                                edge: edge,
                                allowsFullSwipe: allowsFullSwipe
                            ) {
                                node.render()
                            }
                        )
                    }
                    if jsValue != nil && jsValue!.isArray {
                        let cnt = (value as? [Any])?.count ?? 0
                        for i in 0..<cnt {
                            view = addSAFunc(view, jsValue!.atIndex(i))
                        }
                    } else if jsValue != nil {
                        view = addSAFunc(view, jsValue!)
                    }

                //        case "sheet":
                //          if let sheetModifier = value as? [String: Any] {
                //            if var isSheetPresented = sheetModifier["isPresented"] as? Bool {
                //              let isSheetPresentedBinding = Binding<Bool>(
                //                get: { isSheetPresented },
                //                set: { isSheetPresented = $0 }
                //              )
                //              view = AnyView(view.sheet(isPresented: isSheetPresentedBinding, onDismiss: {
                //                onEvent(["onSheetDismissed": true])
                //              }) {
                //                RepresentableView(view: sheetContent ?? UIView())
                //                  .frame(width: sheetContent?.frame.width, height: sheetContent?.frame.height)
                //              })
                //            }
                //          }

                default:
                    break

                }
            }
        }
        return AnyView(view)
    }
}

func convertRGBAToHexString(
    red: CGFloat,
    green: CGFloat,
    blue: CGFloat,
    alpha: CGFloat
) -> String {
    let redInt = Int(red * 255)
    let greenInt = Int(green * 255)
    let blueInt = Int(blue * 255)
    let alphaInt = Int(alpha * 255)
    return String(
        format: "#%02X%02X%02X%02X",
        redInt,
        greenInt,
        blueInt,
        alphaInt
    )
}

//func convertProcessedColorToUIColor(from value: Any?) -> UIColor {
//  do {
//    return try UIColor.convert(from: value, appContext: AppContext())
//  } catch _  {
//    return UIColor.black
//  }
//}

func getColorFromHex(_ hex: String) -> Color? {
    var str = hex
    if str.hasPrefix("#") {
        str.removeFirst()
    }
    if str.count == 3 {
        str =
            String(repeating: str[str.startIndex], count: 2)
            + String(
                repeating: str[str.index(str.startIndex, offsetBy: 1)],
                count: 2
            )
            + String(
                repeating: str[str.index(str.startIndex, offsetBy: 2)],
                count: 2
            )
    } else if !str.count.isMultiple(of: 2) || str.count > 8 {
        return nil
    }
    let scanner = Scanner(string: str)
    var color: UInt64 = 0
    scanner.scanHexInt64(&color)
    if str.count == 2 {
        let gray = Double(Int(color) & 0xFF) / 255
        return Color(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)
    } else if str.count == 4 {
        let gray = Double(Int(color >> 8) & 0x00FF) / 255
        let alpha = Double(Int(color) & 0x00FF) / 255
        return Color(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)
    } else if str.count == 6 {
        let red = Double(Int(color >> 16) & 0x0000FF) / 255
        let green = Double(Int(color >> 8) & 0x0000FF) / 255
        let blue = Double(Int(color) & 0x0000FF) / 255
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    } else if str.count == 8 {
        let red = Double(Int(color >> 24) & 0x0000_00FF) / 255
        let green = Double(Int(color >> 16) & 0x0000_00FF) / 255
        let blue = Double(Int(color >> 8) & 0x0000_00FF) / 255
        let alpha = Double(Int(color) & 0x0000_00FF) / 255
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    } else {
        return nil
    }
}

func getColor(_ color: Any?) -> Color {
    if let color = color as? String {
        switch color {
        case "blue":
            return .blue
        case "red":
            return .red
        case "green":
            return .green
        case "yellow":
            return .yellow
        case "orange":
            return .orange
        case "purple":
            return .purple
        case "pink":
            return .pink
        case "primary":
            return .primary
        case "secondary":
            return .secondary
        case "accentColor":
            return .accentColor
        case "black":
            return .black
        case "white":
            return .white
        case "gray":
            return .gray
        case "clear":
            return .clear
        case "mint":
            if #available(iOS 15.0, *) {
                return .mint
            }
        case "brown":
            if #available(iOS 15.0, *) {
                return .brown
            }
        case "teal":
            if #available(iOS 15.0, *) {
                return .teal
            }
        case "cyan":
            if #available(iOS 15.0, *) {
                return .cyan
            }

        case "indigo":
            if #available(iOS 15.0, *) {
                return .indigo
            }

        default:
            if color.hasPrefix("#") {
                return getColorFromHex(color) ?? .clear
            }

            return .clear
        //      if #available(iOS 15.0, *) {
        //        return Color(uiColor: convertProcessedColorToUIColor(from: color))
        //      } else {
        //        return .clear
        //      }
        }
    }
    return .clear
    //  if #available(iOS 15.0, *) {
    //    return Color(uiColor: convertProcessedColorToUIColor(from: color))
    //  } else {
    //    return .clear
    //  }
}

func getColors(_ colors: [Any]?) -> [Color] {
    var result: [Color] = []
    if let colors = colors {
        for color in colors {
            result.append(getColor(color))
        }
    }
    return result
}

extension DragGesture.Value {
    func toDictionary() -> [String: Any] {
        return [
            "time": time,
            "location": ["x": location.x, "y": location.y],
            "startLocation": ["x": startLocation.x, "y": startLocation.y],
            "translation": [
                "width": translation.width, "height": translation.height,
            ],
            "velocity": ["width": velocity.width, "height": velocity.height],
            "predictedEndLocation": [
                "x": predictedEndLocation.x, "y": predictedEndLocation.y,
            ],
            "predictedEndTranslation": [
                "width": predictedEndTranslation.width,
                "height": predictedEndTranslation.height,
            ],
        ]
    }
}
