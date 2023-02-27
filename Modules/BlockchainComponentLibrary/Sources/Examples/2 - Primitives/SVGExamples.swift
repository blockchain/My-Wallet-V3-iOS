// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

// swiftlint:disable all

@MainActor
struct SVGExamples: View {

    @State var url: String = "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/json.svg"

    var body: some View {
        GeometryReader { geometry in
            #if os(macOS)
            NavigationView {
                content(in: geometry)
            }
            #else
            content(in: geometry)
            #endif
        }
    }

    @ViewBuilder private func content(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .center, spacing: 0) {
            TextField("SVG URL", text: $url)
                .typography(.micro)
                .padding()
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.semantic.light, lineWidth: 1)
                )
            AsyncMedia(
                url: URL(string: url),
                placeholder: { ProgressView().progressViewStyle(.circular) }
            )
            .aspectRatio(contentMode: .fit)
            .frame(width: 90.pmin, in: geometry.frame(in: .global))
            Spacer()
            NavigationLink(
                destination: W3SVGExamples(),
                label: {
                    Text("W3 SVG Examples")
                }
            )
        }
    }
}

struct W3SVGExamples: View {

    let urls: [URL] = [
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/410.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/AJ_Digital_Camera.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/Steps.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/USStates.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/aa.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/accessible.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/acid.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/adobe.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/alphachannel.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/android.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/anim1.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/anim2.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/anim3.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/atom.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/basura.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/beacon.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/betterplace.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/bloglines.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/bzr.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/bzrfeed.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/ca.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/car.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/cartman.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/caution.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/cc.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/ch.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/check.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/circles1.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/clippath.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/compass.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/compuserver_msn_Ford_Focus.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/copyleft.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/copyright.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/couch.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/couchdb.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/cygwin.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/debian.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/decimal.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/dh.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/digg.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/displayWebStats.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/dojo.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/dst.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/duck.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/duke.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/easypeasy.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/eee.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/eff.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/erlang.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/evol.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/facebook.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/faux-art.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/fb.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/feed.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/feedsync.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/fsm.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/gallardo.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/gcheck.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/genshi.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/git.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/gnome2.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/google.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/gpg.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/gump-bench.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/heart.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/heliocentric.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/helloworld.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/hg0.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/http.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/ibm.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/ie-lock.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/ielock.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/ietf.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/image.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/instiki.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/integral.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/intertwingly.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/irony.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/italian-flag.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/iw.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/jabber.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/jquery.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/json.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/jsonatom.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/juanmontoya_lingerie.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/legal.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/m.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/mac.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/mail.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/mars.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/masking-path-04-b.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/mememe.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/microformat.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/mono.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/moonlight.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/mouseEvents.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/mozilla.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/msft.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/msie.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/mt.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/mudflap.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/myspace.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/mysvg.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/no.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/ny1.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/obama.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/odf.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/open-clipart.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/openid.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/opensearch.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/openweb.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/opera.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/osa.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/osi.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/padlock.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/patch.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/paths-data-08-t.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/paths-data-09-t.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/pdftk.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/pencil.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/penrose-staircase.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/penrose-tiling.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/php.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/poi.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/preserveAspectRatio.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/pservers-grad-03-b-anim.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/pservers-grad-03-b.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/pull.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/python.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/rack.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/rails.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/raleigh.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/rdf.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/rectangles.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/rest.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/rfeed.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/rg1024_Presentation_with_girl.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/rg1024_Ufo_in_metalic_style.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/rg1024_eggs.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/rg1024_green_grapes.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/rg1024_metal_effect.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/ruby.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/rubyforge.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/scimitar.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/scion.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/semweb.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/shapes-polygon-01-t.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/shapes-polyline-01-t.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/snake.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/star.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/svg.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/sync.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/tiger.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/tommek_Car.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/twitter.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/ubuntu.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/unicode-han.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/unicode.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/usaf.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/utensils.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/venus.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/video1.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/vmware.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/vnu.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/vote.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/w3c.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/whatwg.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/why.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/wii.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/wikimedia.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/wireless.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/wp.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/wso2.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/x11.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/yadis.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/yahoo.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/yinyang.svg",
        "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/zillow.svg"
    ].compactMap(URL.init(string:))

    @State private var selected: URL?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Text("SVG from dev.w3.org")
                    .typography(.title1)
                    .foregroundColor(.semantic.title)

                LazyVStack(alignment: .center) {
                    ForEach(urls, id: \.self) { url in
                        let isSelected = selected == url
                        AsyncMedia(
                            url: url,
                            content: { svg in
                                svg.aspectRatio(contentMode: .fit)
                                    .frame(width: (isSelected ? 90 : 50).pmin, in: geometry.frame(in: .global))
                            },
                            placeholder: { ProgressView().progressViewStyle(.circular) }
                        )
                        .onTapGesture {
                            withAnimation(.linear) {
                                if isSelected {
                                    selected = nil
                                } else {
                                    selected = url
                                }
                            }
                        }
                        Text(url.absoluteString)
                            .typography(.micro)
                            .foregroundColor(.semantic.body)
                            .padding(.bottom)
                            .contextMenu {
                                Button(
                                    action: {
                                        #if canImport(UIKit)
                                        UIPasteboard.general.string = url.absoluteString
                                        #else
                                        NSPasteboard.general.setString(url.absoluteString, forType: .URL)
                                        #endif
                                    },
                                    label: {
                                        Label("Copy", systemImage: "doc.on.doc.fill")
                                    }
                                )
                            }
                        Divider()
                    }
                }
            }
        }
    }
}
