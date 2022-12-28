import SwiftUI

public enum LayoutConstants {

    public static let fieldCornerRadious: CGFloat = 8
    public static let fieldMinHeight: CGFloat = 48
}

extension LayoutConstants {

    public enum VerticalSpacing {
        public static let betweenContentGroups: CGFloat = 16
        public static let betweenContentGroupsLarge: CGFloat = 24
        public static let withinButtonsGroup: CGFloat = 16
        public static let withinFormGroup: CGFloat = 4
    }
}

extension LayoutConstants {

    enum Text {

        enum FontSize {
            static let title: CGFloat = 20
            static let heading: CGFloat = 16
            static let subheading: CGFloat = 14
            static let body: CGFloat = 14
            static let formField: CGFloat = 16
        }

        enum LineHeight {
            static let title: CGFloat = 30
            static let heading: CGFloat = 24
            static let subheading: CGFloat = 20
            static let body: CGFloat = 20
            static let formField: CGFloat = 24
        }

        enum LineSpacing {
            static let title: CGFloat = LineHeight.title - FontSize.title
            static let heading: CGFloat = LineHeight.heading - FontSize.heading
            static let subheading: CGFloat = LineHeight.subheading - FontSize.subheading
            static let body: CGFloat = LineHeight.body - FontSize.body
            static let formField: CGFloat = LineHeight.formField - FontSize.formField
        }
    }
}
