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

        width: 90,

        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),

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

    child: SizedBox(
    height: 90,
    child: FittedBox(
    fit: BoxFit.scaleDown,
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [

          CircleAvatar(
          radius: 16,
          backgroundColor: selected
              ? Colors.white
              : TColors.primary,
          child: Text(
            area.doctorCount.toString(),
            style: TextStyle(
              color: selected
                  ? TColors.primary
                  : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
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
              "PIN ${area.pincode}",
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
          ),
      ),
    );

  }

}