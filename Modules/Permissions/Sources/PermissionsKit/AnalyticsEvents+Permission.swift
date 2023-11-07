// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents {
    public enum Permission: AnalyticsEvent {
        case permissionPreCameraApprove
        case permissionPreCameraDecline
        case permissionSysCameraApprove
        case permissionSysCameraDecline
        case permissionPreMicApprove
        case permissionPreMicDecline
        case permissionSysMicApprove
        case permissionSysMicDecline

        public var name: String {
            switch self {
            // Permission - camera preliminary approve
            case .permissionPreCameraApprove:
                "permission_pre_camera_approve"
            // Permission - camera preliminary decline
            case .permissionPreCameraDecline:
                "permission_pre_camera_decline"
            // Permission - camera system approve
            case .permissionSysCameraApprove:
                "permission_sys_camera_approve"
            // Permission - camera system decline
            case .permissionSysCameraDecline:
                "permission_sys_camera_decline"
            // Permission - mic preliminary approve
            case .permissionPreMicApprove:
                "permission_pre_mic_approve"
            // Permission - mic preliminary decline
            case .permissionPreMicDecline:
                "permission_pre_mic_decline"
            // Permission - mic system approve
            case .permissionSysMicApprove:
                "permission_sys_mic_approve"
            // Permission - mic system decline
            case .permissionSysMicDecline:
                "permission_sys_mic_decline"
            }
        }
    }
}
