import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../controller/territory_controller.dart';
import '../model/area_model.dart';

class AreaCircleWidget extends GetView<TerritoryController> {

  final AreaModel area;

  const AreaCircleWidget({
    super.key,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {

    final selected = controller.isAreaSelected(area.id);

    final selectedBeat =
        controller.selectedBeat.value;

    return GestureDetector(

      onTap: (){

        controller.selectArea(area);

      },

      child: AnimatedContainer(

        duration: const Duration(
          milliseconds: 250,
        ),

        width: 110,

        padding: const EdgeInsets.all(8),

        decoration: BoxDecoration(

          color: selected
              ? TColors.primary
              : Colors.white,

          borderRadius:
          BorderRadius.circular(18),

          border: Border.all(

            color: selected
                ? TColors.primary
                : Colors.blue,

          ),

          boxShadow: const [

            BoxShadow(

              color: Colors.black12,

              blurRadius: 8,

            )

          ],

        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(

              Icons.location_city,

              size: 22,

              color: selected
                  ? Colors.white
                  : TColors.primary,

            ),

            const SizedBox(height: 6),

            Text(

              area.postOffice,

              textAlign: TextAlign.center,

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(

                fontWeight: FontWeight.bold,

                fontSize:
                TSizes.fontSizeSm,

                color: selected
                    ? Colors.white
                    : Colors.black,

              ),

            ),

            const SizedBox(height: 4),

            Text(

              "${area.doctorCount} Doctors",

              style: TextStyle(

                fontSize: 11,

                color: selected
                    ? Colors.white70
                    : Colors.grey,

              ),

            ),

            Text(

              area.pincode,

              style: TextStyle(

                fontSize: 10,

                color: selected
                    ? Colors.white70
                    : Colors.grey,

              ),

            ),

          ],

        ),

      ),

    );

  }

}