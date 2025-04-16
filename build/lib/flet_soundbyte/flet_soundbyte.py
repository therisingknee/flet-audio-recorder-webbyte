# from enum import Enum
# from typing import Any, Optional
#
# from flet.core.constrained_control import ConstrainedControl
# from flet.core.control import OptionalNumber
#
#
# class FletSoundbyte(ConstrainedControl):
#     """
#     FletSoundbyte Control description.
#     """
#
#     def __init__(
#             self,
#             #
#             # Control
#             #
#             opacity: OptionalNumber = None,
#             tooltip: Optional[str] = None,
#             visible: Optional[bool] = None,
#             data: Any = None,
#             #
#             # ConstrainedControl
#             #
#             left: OptionalNumber = None,
#             top: OptionalNumber = None,
#             right: OptionalNumber = None,
#             bottom: OptionalNumber = None,
#             #
#             # FletSoundbyte specific
#             #
#             value: Optional[str] = None,
#     ):
#         ConstrainedControl.__init__(
#             self,
#             tooltip=tooltip,
#             opacity=opacity,
#             visible=visible,
#             data=data,
#             left=left,
#             top=top,
#             right=right,
#             bottom=bottom,
#         )
#
#         self.value = value
#
#     def _get_control_name(self):
#         return "flet_soundbyte"
#
#     # value
#     @property
#     def value(self):
#         """
#         Value property description.
#         """
#         return self._get_attr("value")
#
#     @value.setter
#     def value(self, value):
#         self._set_attr("value", value)

from flet.core.constrained_control import ConstrainedControl
from flet.core.control import OptionalNumber
from flet.core.control_event import ControlEvent
from typing import Optional, Any


class FletSoundbyte(ConstrainedControl):
    def __init__(
            self,
            value: Optional[str] = None,
            opacity: OptionalNumber = None,
            tooltip: Optional[str] = None,
            visible: Optional[bool] = None,
            data: Any = None,
            left: OptionalNumber = None,
            top: OptionalNumber = None,
            right: OptionalNumber = None,
            bottom: OptionalNumber = None,
            on_event=None,
    ):
        super().__init__(
            opacity=opacity,
            tooltip=tooltip,
            visible=visible,
            data=data,
            left=left,
            top=top,
            right=right,
            bottom=bottom,
        )

        self.value = value
        self._add_event_handler("audio_recorded", on_event)

    def _get_control_name(self):
        return "flet_soundbyte"

    @property
    def value(self):
        return self._get_attr("value")

    @value.setter
    def value(self, value):
        self._set_attr("value", value)
